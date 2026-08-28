//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation
import SwiftData

@available(iOS 17.0, *)
@available(tvOS, unavailable)
final class URLAssetDownloadStore {
    let context: ModelContext

    init(name: String? = nil) throws {
        let schema = Schema([Entry.self])
        let modelConfiguration = ModelConfiguration(name, schema: schema, isStoredInMemoryOnly: false)
        self.context = .init(try ModelContainer(for: schema, configurations: [modelConfiguration]))
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
private extension URLAssetDownloadStore {
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

        init(assetMetadata: AssetMetadata<Void>) {
            self.entryPlayerMetadata = .init(playerMetadata: assetMetadata.playerMetadata)
        }

        func assetMetadata() -> AssetMetadata<Void> {
            .init(playerMetadata: entryPlayerMetadata.playerMetadata(), customData: ())
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

        private var url: URL
        private var configuration: DownloadConfiguration
        private var metadata: EntryAssetMetadata
        private var bookmarkData: Data?
        private var progress: Double
        private var error: EntryError?
        private var creationDate: Date

        init(id: String, record: DownloadRecord<URLAssetLoader.Input, Void>) {
            self.id = id
            self.url = record.input.url
            self.configuration = record.configuration
            self.metadata = .init(assetMetadata: .init(playerMetadata: record.input.metadata, customData: ()))
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

        func toRecord() -> DownloadRecord<URLAssetLoader.Input, Void> {
            let assetMetadata = metadata.assetMetadata()
            return .init(
                input: .init(url: url, metadata: assetMetadata.playerMetadata),
                configuration: configuration,
                metadata: assetMetadata,
                bookmarkData: bookmarkData,
                progress: progress,
                error: error?.error(),
                creationDate: creationDate
            )
        }

        func update(with record: DownloadRecord<URLAssetLoader.Input, Void>) {
            self.url = record.input.url
            self.configuration = record.configuration
            self.metadata = .init(assetMetadata: .init(playerMetadata: record.input.metadata, customData: ()))
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
extension URLAssetDownloadStore: AssetDownloadStore {
    typealias Loader = URLAssetLoader

    static func id(from input: URLAssetLoader.Input) -> String {
        input.url.absoluteString
    }

    static func customData(from metadata: Void) {}

    func downloadRecords() -> [DownloadRecord<URLAssetLoader.Input, Void>] {
        guard let entries = try? context.fetch(FetchDescriptor<Entry>()) else { return [] }
        return entries.map { $0.toRecord() }
    }

    func addDownloadRecord(_ record: DownloadRecord<URLAssetLoader.Input, Void>, forId id: String) {
        context.insert(Entry(id: id, record: record))
    }

    func removeDownloadRecord(forId id: String) {
        try? context.delete(model: Entry.self, where: Entry.predicate(for: id))
    }

    func downloadRecord(forId id: String) -> DownloadRecord<URLAssetLoader.Input, Void>? {
        entry(forId: id)?.toRecord()
    }

    func updateDownloadRecord(_ record: DownloadRecord<URLAssetLoader.Input, Void>, forId id: String) {
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
