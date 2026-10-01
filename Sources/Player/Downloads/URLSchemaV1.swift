//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import SwiftData

@available(iOS 17.0, *)
@available(tvOS, unavailable)
enum URLSchemaV1<CustomData> where CustomData: Codable {
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
        private let customData: CustomData

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

        init(assetMetadata: AssetMetadata<CustomData>) {
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

        func assetMetadata() -> AssetMetadata<CustomData> {
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

    @Model
    final class URLEntryError {
        private var domain: String
        private var code: Int
        private var localizedDescription: String

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

        @Relationship(deleteRule: .cascade)
        private var error: URLEntryError?

        private var creationDate: Date

        init(id: String, record: DownloadRecord<URLInput<CustomData>, CustomData>) {
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

        func toRecord() -> DownloadRecord<URLInput<CustomData>, CustomData> {
            let assetMetadata = metadata.assetMetadata()
            return .init(
                input: .init(url: url, metadata: assetMetadata),
                configuration: configuration,
                metadata: assetMetadata,
                bookmarkData: bookmarkData,
                progress: progress,
                error: error?.error(),
                creationDate: creationDate
            )
        }

        func update(with record: DownloadRecord<URLInput<CustomData>, CustomData>) {
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

@available(iOS 17.0, *)
@available(tvOS, unavailable)
extension URLSchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [URLEntry.self]
    }

    static var versionIdentifier: Schema.Version {
        .init(1, 0, 0)
    }
}
