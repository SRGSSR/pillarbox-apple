//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

import SwiftData

@available(iOS 17.0, *)
@available(tvOS, unavailable)
final class StandardAssetDownloadStore<Provider> where Provider: StandardAssetDownloadStoreProvider {
    let context: ModelContext

    init(name: String? = nil, providerType: Provider.Type) throws {
        let schema = Schema([StandardEntry.self])
        let modelConfiguration = ModelConfiguration(name, schema: schema, isStoredInMemoryOnly: false)
        self.context = .init(try ModelContainer(for: schema, configurations: [modelConfiguration]))
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
private extension StandardAssetDownloadStore {
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
        private let customData: Provider.CustomData?

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

        init?(assetMetadata: AssetMetadata<Provider.CustomData?>?) {
            guard let assetMetadata else { return nil }
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

        func assetMetadata() -> AssetMetadata<Provider.CustomData?> {
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
    final class StandardEntry {
        @Attribute(.unique)
        var id: String

        private var input: Provider.Input
        private var configuration: DownloadConfiguration
        private var metadata: EntryAssetMetadata?
        private var bookmarkData: Data?
        private var progress: Double
        private var error: EntryError?
        private var creationDate: Date

        init(id: String, record: DownloadRecord<Provider.Input, Provider.CustomData?>) {
            self.id = id
            self.input = record.input
            self.configuration = record.configuration
            self.metadata = .init(assetMetadata: record.metadata)
            self.bookmarkData = record.bookmarkData
            self.progress = record.progress
            self.error = .init(error: record.error)
            self.creationDate = record.creationDate
        }

        static func predicate(for id: String) -> Predicate<StandardEntry> {
            #Predicate { entry in
                entry.id == id
            }
        }

        func toRecord() -> DownloadRecord<Provider.Input, Provider.CustomData?> {
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

        func update(with record: DownloadRecord<Provider.Input, Provider.CustomData?>) {
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

@available(iOS 17.0, *)
@available(tvOS, unavailable)
extension StandardAssetDownloadStore: AssetDownloadStore {
    typealias Loader = StandardAssetLoader<Provider>

    static func id(from input: Provider.Input) -> String {
        Provider.id(from: input)
    }

    static func customData(from metadata: PlayerData<Provider.CustomData>) -> Provider.CustomData? {
        metadata.customData
    }

    static func asset(fileUrl: URL, customData: Provider.CustomData?) -> Asset {
        Provider.asset(fileUrl: fileUrl, customData: customData)
    }

    func downloadRecords() -> [DownloadRecord<Provider.Input, Provider.CustomData?>] {
        guard let entries = try? context.fetch(FetchDescriptor<StandardEntry>()) else { return [] }
        return entries.map { $0.toRecord() }
    }

    func addDownloadRecord(_ record: DownloadRecord<Provider.Input, Provider.CustomData?>, forId id: String) {
        context.insert(StandardEntry(id: id, record: record))
    }

    func removeDownloadRecord(forId id: String) {
        try? context.delete(model: StandardEntry.self, where: StandardEntry.predicate(for: id))
    }

    func downloadRecord(forId id: String) -> DownloadRecord<Provider.Input, Provider.CustomData?>? {
        entry(forId: id)?.toRecord()
    }

    func updateDownloadRecord(_ record: DownloadRecord<Provider.Input, Provider.CustomData?>, forId id: String) {
        guard let entry = entry(forId: id) else { return }
        entry.update(with: record)
        try? context.save()
    }

    private func entry(forId id: String) -> StandardEntry? {
        let descriptor = FetchDescriptor(predicate: StandardEntry.predicate(for: id))
        return try? context.fetch(descriptor).first
    }
}
