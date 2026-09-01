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
final class URNAssetDownloadStore {
    let context: ModelContext

    init(name: String? = nil) throws {
        let schema = Schema([URNEntry.self])
        let modelConfiguration = ModelConfiguration(name, schema: schema, isStoredInMemoryOnly: false)
        self.context = .init(try ModelContainer(for: schema, configurations: [modelConfiguration]))
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
private extension URNAssetDownloadStore {
    struct EntryPlayerMetadata: Codable {
        let identifier: String?
        let title: String?
        let subtitle: String?
        let summary: String?
        let imageUrl: URL?
        let imageData: Data?
        let viewport: Viewport
        let episode: Int?
        let season: Int?
        let chapters: [Chapter]
        let timeRanges: [TimeRange]

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
            self.entryPlayerMetadata = .init(
                identifier: assetMetadata.identifier,
                title: assetMetadata.title,
                subtitle: assetMetadata.subtitle,
                summary: assetMetadata.description,
                imageUrl: assetMetadata.imageSource.url,
                imageData: assetMetadata.imageSource.data,
                viewport: assetMetadata.viewport,
                episode: assetMetadata.episodeInformation?.episode,
                season: assetMetadata.episodeInformation?.season,
                chapters: assetMetadata.chapters,
                timeRanges: assetMetadata.timeRanges
            )
            self.customData = assetMetadata.customData
        }

        func assetMetadata() -> AssetMetadata<URNMetadata> {
            let playerMetadata = entryPlayerMetadata.playerMetadata()
            return .init(
                identifier: playerMetadata.identifier,
                title: playerMetadata.title,
                subtitle: playerMetadata.subtitle,
                description: playerMetadata.description,
                imageSource: playerMetadata.imageSource,
                viewport: playerMetadata.viewport,
                episodeInformation: playerMetadata.episodeInformation,
                chapters: playerMetadata.chapters,
                timeRanges: playerMetadata.timeRanges,
                customData: customData
            )
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
    final class URNEntry {
        @Attribute(.unique)
        var id: String

        private var input: URNAssetLoader.Input
        private var configuration: DownloadConfiguration
        private var metadata: EntryAssetMetadata?
        private var bookmarkData: Data?
        private var progress: Double
        private var error: EntryError?
        private var creationDate: Date

        init(id: String, record: DownloadRecord<URNAssetLoader.Input, URNMetadata>) {
            self.id = id
            self.input = record.input
            self.configuration = record.configuration
            self.metadata = .init(assetMetadata: record.metadata)
            self.bookmarkData = record.bookmarkData
            self.progress = record.progress
            self.error = .init(error: record.error)
            self.creationDate = record.creationDate
        }

        static func predicate(for id: String) -> Predicate<URNEntry> {
            #Predicate { entry in
                entry.id == id
            }
        }

        func toRecord() -> DownloadRecord<URNAssetLoader.Input, URNMetadata> {
            .init(
                input: input,
                configuration: configuration,
                metadata: metadata?.assetMetadata(),
                bookmarkData: bookmarkData,
                progress: progress,
                error: error?.error(),
                creationDate: creationDate
            )
        }

        func update(with record: DownloadRecord<URNAssetLoader.Input, URNMetadata>) {
            self.input = record.input
            self.configuration = record.configuration
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
        guard let entries = try? context.fetch(FetchDescriptor<URNEntry>()) else { return [] }
        return entries.map { $0.toRecord() }
    }

    func addDownloadRecord(_ record: DownloadRecord<URNAssetLoader.Input, URNMetadata>, forId id: String) {
        context.insert(URNEntry(id: id, record: record))
    }

    func removeDownloadRecord(forId id: String) {
        try? context.delete(model: URNEntry.self, where: URNEntry.predicate(for: id))
    }

    func downloadRecord(forId id: String) -> DownloadRecord<URNAssetLoader.Input, URNMetadata>? {
        entry(forId: id)?.toRecord()
    }

    func updateDownloadRecord(_ record: DownloadRecord<URNAssetLoader.Input, URNMetadata>, forId id: String) {
        guard let entry = entry(forId: id) else { return }
        entry.update(with: record)
        try? context.save()
    }

    private func entry(forId id: String) -> URNEntry? {
        let descriptor = FetchDescriptor(predicate: URNEntry.predicate(for: id))
        return try? context.fetch(descriptor).first
    }
}

#endif
