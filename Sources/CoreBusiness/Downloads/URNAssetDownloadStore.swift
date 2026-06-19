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
        let identifier: String?
        let title: String?
        let subtitle: String?
        let summary: String?
        let viewport: Viewport
        let episodeInformation: SafeSwiftDataOptional<EpisodeInformation>
        let chapters: [Chapter]
        let timeRanges: [TimeRange]

        init(playerMetadata: PlayerMetadata) {
            self.identifier = playerMetadata.identifier
            self.title = playerMetadata.title
            self.subtitle = playerMetadata.subtitle
            self.summary = playerMetadata.description
            self.viewport = playerMetadata.viewport
            self.episodeInformation = .init(wrappedValue: playerMetadata.episodeInformation)
            self.chapters = playerMetadata.chapters
            self.timeRanges = playerMetadata.timeRanges
        }

        func playerMetadata() -> PlayerMetadata {
            .init(
                identifier: identifier,
                title: title,
                subtitle: subtitle,
                description: summary,
                viewport: viewport,
                episodeInformation: episodeInformation.wrappedValue,
                chapters: chapters,
                timeRanges: timeRanges
            )
        }
    }

    struct EntryAssetMetadata: Codable {
        let entryPlayerMetadata: EntryPlayerMetadata
        let customData: URNMetadata

        init?(assetMetadata: AssetMetadata<URNMetadata>?) {
            guard let assetMetadata else { return nil }
            self.entryPlayerMetadata = .init(playerMetadata: assetMetadata.playerMetadata)
            self.customData = assetMetadata.customData
        }

        func assetMetadata() -> AssetMetadata<URNMetadata> {
            .init(playerMetadata: entryPlayerMetadata.playerMetadata(), customData: customData)
        }
    }

    @Model
    final class Entry {
        @Attribute(.unique)
        var id: String
        var input: URNAssetLoader.Input
        var entryAssetMetadata: EntryAssetMetadata?
        var bookmarkData: Data?
        var progress: Double
        var errorDescription: String?

        init(
            id: String,
            input: URNAssetLoader.Input,
            entryAssetMetadata: EntryAssetMetadata? = nil,
            bookmarkData: Data? = nil,
            progress: Double,
            errorDescription: String? = nil
        ) {
            self.id = id
            self.input = input
            self.entryAssetMetadata = entryAssetMetadata
            self.bookmarkData = bookmarkData
            self.progress = progress
            self.errorDescription = errorDescription
        }

        static func predicate(for id: String) -> Predicate<Entry> {
            #Predicate { entry in
                entry.id == id
            }
        }

        func toRecord() -> DownloadRecord<URNAssetLoader.Input, URNMetadata> {
            .init(
                input: input,
                metadata: entryAssetMetadata?.assetMetadata(),
                bookmarkData: bookmarkData,
                progress: progress,
                error: DownloadError(errorDescription: errorDescription)
            )
        }

        func update(with record: DownloadRecord<URNAssetLoader.Input, URNMetadata>) {
            self.input = record.input
            self.entryAssetMetadata = .init(assetMetadata: record.metadata)
            self.bookmarkData = record.bookmarkData
            self.progress = record.progress
            self.errorDescription = record.error?.localizedDescription
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
        .init(analyticsMetadata: metadata.analyticsMetadata)
    }

    func downloadRecords() -> [DownloadRecord<URNAssetLoader.Input, URNMetadata>] {
        guard let entries = try? context.fetch(FetchDescriptor<Entry>()) else { return [] }
        return entries.map { $0.toRecord() }
    }

    func addDownloadRecord(using input: URNAssetLoader.Input, forId id: String) {
        context.insert(Entry(id: id, input: input, progress: 0))
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
