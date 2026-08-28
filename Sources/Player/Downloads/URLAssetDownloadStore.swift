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
final class URLAssetDownloadStore<CustomData: Codable> {
    let context: ModelContext

    init(name: String? = nil) throws {
        let schema = Schema([URLEntry.self])
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
        private let customData: CustomData

        init(assetMetadata: AssetMetadata<CustomData>) {
            self.entryPlayerMetadata = .init(playerMetadata: assetMetadata.playerMetadata)
            self.customData = assetMetadata.customData
        }

        func assetMetadata() -> AssetMetadata<CustomData> {
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
    final class URLEntry {
        @Attribute(.unique)
        var id: String

        private var url: URL
        private var configuration: DownloadConfiguration
        private var metadata: EntryAssetMetadata
        private var bookmarkData: Data?
        private var progress: Double
        private var error: EntryError?
        private var creationDate: Date

        init(id: String, record: DownloadRecord<URLAssetLoader<CustomData>.Input, CustomData>) {
            self.id = id
            self.url = record.input.url
            self.configuration = record.configuration
            self.metadata = .init(assetMetadata: record.input.metadata)
            self.bookmarkData = record.bookmarkData
            self.progress = record.progress
            self.error = .init(error: record.error)
            self.creationDate = record.creationDate
        }

        static func predicate(for id: String) -> Predicate<URLEntry> {
            #Predicate { entry in
                entry.id == id
            }
        }

        func toRecord() -> DownloadRecord<URLAssetLoader<CustomData>.Input, CustomData> {
            .init(
                input: .init(url: url, metadata: metadata.assetMetadata()),
                configuration: configuration,
                metadata: metadata.assetMetadata(),
                bookmarkData: bookmarkData,
                progress: progress,
                error: error?.error(),
                creationDate: creationDate
            )
        }

        func update(with record: DownloadRecord<URLAssetLoader<CustomData>.Input, CustomData>) {
            self.url = record.input.url
            self.configuration = record.configuration
            self.metadata = .init(assetMetadata: record.input.metadata)
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
    typealias Loader = URLAssetLoader<CustomData>

    static func id(from input: URLAssetLoader<CustomData>.Input) -> String {
        input.url.absoluteString
    }

    static func customData(from metadata: AssetMetadata<CustomData>) -> CustomData {
        metadata.customData
    }

    func downloadRecords() -> [DownloadRecord<URLAssetLoader<CustomData>.Input, CustomData>] {
        guard let entries = try? context.fetch(FetchDescriptor<URLEntry>()) else { return [] }
        return entries.map { $0.toRecord() }
    }

    func addDownloadRecord(_ record: DownloadRecord<URLAssetLoader<CustomData>.Input, CustomData>, forId id: String) {
        context.insert(URLEntry(id: id, record: record))
    }

    func removeDownloadRecord(forId id: String) {
        try? context.delete(model: URLEntry.self, where: URLEntry.predicate(for: id))
    }

    func downloadRecord(forId id: String) -> DownloadRecord<URLAssetLoader<CustomData>.Input, CustomData>? {
        entry(forId: id)?.toRecord()
    }

    func updateDownloadRecord(_ record: DownloadRecord<URLAssetLoader<CustomData>.Input, CustomData>, forId id: String) {
        guard let entry = entry(forId: id) else { return }
        entry.update(with: record)
        try? context.save()
    }

    private func entry(forId id: String) -> URLEntry? {
        let descriptor = FetchDescriptor(predicate: URLEntry.predicate(for: id))
        return try? context.fetch(descriptor).first
    }
}

#endif
