//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import SwiftData

@available(iOS 17.0, *)
@available(tvOS, unavailable)
final class URLAssetDownloadStore<Provider> where Provider: URLAssetProvider {
    let context: ModelContext

    init(name: String? = nil, providerType: Provider.Type) throws {
        let schema = Schema([URLEntry.self])
        let modelConfiguration = ModelConfiguration(name, schema: schema, isStoredInMemoryOnly: false)
        self.context = .init(try ModelContainer(for: schema, configurations: [modelConfiguration]))
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
private extension URLAssetDownloadStore {
    struct EntryAssetMetadata: Codable {
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
        private let customData: Provider.CustomData

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

        init(assetMetadata: AssetMetadata<Provider.CustomData>) {
            self.identifier = assetMetadata.identifier
            self.title = assetMetadata.title
            self.subtitle = assetMetadata.subtitle
            self.summary = assetMetadata.description
            self.imageData = assetMetadata.imageSource.data
            self.imageUrl = assetMetadata.imageSource.url
            self.viewport = assetMetadata.viewport
            self.episode = assetMetadata.episodeInformation?.episode
            self.season = assetMetadata.episodeInformation?.season
            self.chapters = assetMetadata.chapters
            self.timeRanges = assetMetadata.timeRanges
            self.customData = assetMetadata.customData
        }

        func assetMetadata() -> AssetMetadata<Provider.CustomData> {
            .init(
                identifier: identifier,
                title: title,
                subtitle: subtitle,
                description: summary,
                imageSource: imageSource,
                viewport: viewport,
                episodeInformation: episodeInformation,
                chapters: chapters,
                timeRanges: timeRanges,
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

        init(id: String, record: DownloadRecord<URLAssetLoader<Provider.CustomData>.Input, Provider.CustomData>) {
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

        func toRecord() -> DownloadRecord<URLAssetLoader<Provider.CustomData>.Input, Provider.CustomData> {
            let assetMetadata = metadata.assetMetadata()
            return .init(
                // TODO: Configuration
                input: .init(url: url, metadata: assetMetadata),
                configuration: configuration,
                metadata: assetMetadata,
                bookmarkData: bookmarkData,
                progress: progress,
                error: error?.error(),
                creationDate: creationDate
            )
        }

        func update(with record: DownloadRecord<URLAssetLoader<Provider.CustomData>.Input, Provider.CustomData>) {
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
    typealias Loader = URLAssetLoader<Provider.CustomData>

    static func id(from input: URLAssetLoader<Provider.CustomData>.Input) -> String {
        input.url.absoluteString
    }

    static func customData(from metadata: AssetMetadata<Provider.CustomData>) -> Provider.CustomData {
        metadata.customData
    }

    static func asset(fileUrl: URL, customData: Provider.CustomData) -> Asset {
        // TODO: Configuration
        Provider.asset(fileUrl: fileUrl, configuration: .default, customData: customData)
    }

    func downloadRecords() -> [DownloadRecord<URLAssetLoader<Provider.CustomData>.Input, Provider.CustomData>] {
        guard let entries = try? context.fetch(FetchDescriptor<URLEntry>()) else { return [] }
        return entries.map { $0.toRecord() }
    }

    func addDownloadRecord(_ record: DownloadRecord<URLAssetLoader<Provider.CustomData>.Input, Provider.CustomData>, forId id: String) {
        context.insert(URLEntry(id: id, record: record))
    }

    func removeDownloadRecord(forId id: String) {
        try? context.delete(model: URLEntry.self, where: URLEntry.predicate(for: id))
    }

    func downloadRecord(forId id: String) -> DownloadRecord<URLAssetLoader<Provider.CustomData>.Input, Provider.CustomData>? {
        entry(forId: id)?.toRecord()
    }

    func updateDownloadRecord(_ record: DownloadRecord<URLAssetLoader<Provider.CustomData>.Input, Provider.CustomData>, forId id: String) {
        guard let entry = entry(forId: id) else { return }
        entry.update(with: record)
        try? context.save()
    }

    private func entry(forId id: String) -> URLEntry? {
        let descriptor = FetchDescriptor(predicate: URLEntry.predicate(for: id))
        return try? context.fetch(descriptor).first
    }
}
