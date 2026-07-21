//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation
import SwiftData

@_spi(DownloaderPrivate)
import PillarboxPlayer

@available(iOS 17.0, *)
@available(tvOS, unavailable)
private struct DownloadError: LocalizedError {
    let errorDescription: String?

    init?(errorDescription: String?) {
        guard let errorDescription else { return nil }
        self.errorDescription = errorDescription
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
final class URNAssetDownloadStore {
    let context: ModelContext

    init(name: String? = nil) throws {
        let schema = Schema([Entry.self])
        let modelConfiguration = ModelConfiguration(name, schema: schema, isStoredInMemoryOnly: false)
        self.context = .init(try ModelContainer(for: schema, configurations: [modelConfiguration]))
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
private extension URNAssetDownloadStore {
    struct EntryPlayerMetadata: Codable {
        private let identifier: String?
        private let title: String?
        private let subtitle: String?
        private let summary: String?
        private let imageUrl: URL?
        private let imageData: Data?
        private let viewport: Viewport
        private let episode: Int?
        private let season: Int?
        private let chapters: [Chapter]
        private let timeRanges: [TimeRange]

        private var imageSource: ImageSource {
            if let imageData {
                return .image(imageData)
            }
            else if let imageUrl {
                return .url(standardResolution: imageUrl)
            }
            else {
                return .none
            }
        }

        private var episodeInformation: EpisodeInformation? {
            guard let episode else { return nil }
            if let season {
                return .init(episode: episode, season: season)
            }
            else {
                return .init(episode: episode)
            }
        }

        init(playerMetadata: PlayerMetadata) {
            self.identifier = playerMetadata.identifier
            self.title = playerMetadata.title
            self.subtitle = playerMetadata.subtitle
            self.summary = playerMetadata.description
            self.imageData = playerMetadata.imageSource.data
            self.imageUrl = playerMetadata.imageSource.url
            self.viewport = playerMetadata.viewport
            self.episode = playerMetadata.episodeInformation?.episode
            self.season = playerMetadata.episodeInformation?.season
            self.chapters = playerMetadata.chapters
            self.timeRanges = playerMetadata.timeRanges
        }

        func playerMetadata() -> PlayerMetadata {
            .init(
                identifier: identifier,
                title: title,
                subtitle: subtitle,
                description: summary,
                imageSource: imageSource,
                viewport: viewport,
                episodeInformation: episodeInformation,
                chapters: chapters,
                timeRanges: timeRanges
            )
        }
    }

    struct EntryAssetMetadata: Codable {
        private let entryPlayerMetadata: EntryPlayerMetadata
        private let customData: URNMetadata

        init?(assetMetadata: AssetMetadata<URNMetadata>?) {
            guard let assetMetadata else { return nil }
            self.entryPlayerMetadata = .init(playerMetadata: assetMetadata.playerMetadata)
            self.customData = assetMetadata.customData
        }

        func assetMetadata() -> AssetMetadata<URNMetadata> {
            .init(playerMetadata: entryPlayerMetadata.playerMetadata(), customData: customData)
        }
    }

    struct EntryError: Codable {
        private let domain: String
        private let code: Int
        private let localizedDescription: String

        init?(error: Error?) {
            guard let error else { return nil }
            let nsError = error as NSError
            self.domain = nsError.domain
            self.code = nsError.code
            self.localizedDescription = nsError.localizedDescription
        }

        func error() -> Error {
            NSError(domain: domain, code: code, userInfo: [
                NSLocalizedDescriptionKey: localizedDescription
            ])
        }
    }

    @Model
    final class Entry {
        @Attribute(.unique)
        var id: String

        private var input: URNAssetLoader.Input
        private var metadata: EntryAssetMetadata?
        private var bookmarkData: Data?
        private var progress: Double
        private var error: EntryError?
        private var creationDate: Date

        init(id: String, record: DownloadRecord<URNAssetLoader.Input, URNMetadata>) {
            self.id = id
            self.input = record.input
            self.metadata = .init(assetMetadata: record.metadata)
            self.bookmarkData = record.bookmarkData
            self.progress = record.progress
            self.error = .init(error: record.error)
            self.creationDate = record.creationDate
        }

        static func predicate(for id: String) -> Predicate<Entry> {
            #Predicate { entry in
                entry.id == id
            }
        }

        func toRecord() -> DownloadRecord<URNAssetLoader.Input, URNMetadata> {
            .init(
                input: input,
                metadata: metadata?.assetMetadata(),
                bookmarkData: bookmarkData,
                progress: progress,
                error: error?.error(),
                creationDate: creationDate
            )
        }

        func update(with record: DownloadRecord<URNAssetLoader.Input, URNMetadata>) {
            self.input = record.input
            self.metadata = .init(assetMetadata: record.metadata)
            self.bookmarkData = record.bookmarkData
            self.progress = record.progress
            self.error = .init(error: record.error)
            self.creationDate = record.creationDate
        }
    }
}

@_spi(DownloaderPrivate)
@available(iOS 17.0, *)
@available(tvOS, unavailable)
extension URNAssetDownloadStore: AssetDownloadStore {
    typealias Loader = URNAssetLoader

    static func id(from input: URNAssetLoader.Input) -> String {
        input.id
    }

    static func customData(from metadata: MediaMetadata) -> URNMetadata {
        .init(analyticsData: metadata.analyticsData, analyticsMetadata: metadata.analyticsMetadata)
    }

    static func playerMetadata(from input: URNAssetLoader.Input, metadata: MediaMetadata?) -> PlayerMetadata {
        metadata?.playerMetadata(dateFormat: .standard) ?? .empty
    }

    func downloadRecords() -> [DownloadRecord<URNAssetLoader.Input, URNMetadata>] {
        guard let entries = try? context.fetch(FetchDescriptor<Entry>()) else { return [] }
        return entries.map { $0.toRecord() }
    }

    func addDownloadRecord(_ record: DownloadRecord<URNAssetLoader.Input, URNMetadata>, forId id: String) {
        context.insert(Entry(id: id, record: record))
    }

    func removeDownloadRecord(forId id: String) {
        try? context.delete(model: Entry.self, where: Entry.predicate(for: id))
    }

    func downloadRecord(forId id: String) -> DownloadRecord<URNAssetLoader.Input, URNMetadata>? {
        entry(forId: id)?.toRecord()
    }

    func updateDownloadRecord(_ record: DownloadRecord<URNAssetLoader.Input, URNMetadata>, forId id: String) {
        guard let entry = entry(forId: id) else { return }
        entry.update(with: record)
        try? context.save()
    }

    private func entry(forId id: String) -> Entry? {
        let descriptor = FetchDescriptor(predicate: Entry.predicate(for: id))
        return try? context.fetch(descriptor).first
    }
}

#endif
