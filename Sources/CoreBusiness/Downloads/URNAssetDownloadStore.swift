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

    init() {
        let schema = Schema([Entry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        self.context = .init(try! ModelContainer(for: schema, configurations: [modelConfiguration]))
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
extension URNAssetDownloadStore {
    @Model
    class EntryMetadata {
        var identifier: String?
        var title: String?
        var subtitle: String?
        // swiftlint:disable:next discouraged_optional_collection
        var analyticsData: [String: String]?
        // swiftlint:disable:next discouraged_optional_collection
        var analyticsMetadata: [String: String]?

        var urnMetadata: URNMetadata {
            URNMetadata(
                identifier: identifier,
                title: title,
                subtitle: subtitle,
                analyticsData: analyticsData ?? [:],
                analyticsMetadata: analyticsMetadata ?? [:]
            )
        }

        init(
            identifier: String? = nil,
            title: String? = nil,
            subtitle: String? = nil,
            // swiftlint:disable:next discouraged_optional_collection
            analyticsData: [String: String]? = nil,
            // swiftlint:disable:next discouraged_optional_collection
            analyticsMetadata: [String: String]? = nil
        ) {
            self.identifier = identifier
            self.title = title
            self.subtitle = subtitle
            self.analyticsData = analyticsData
            self.analyticsMetadata = analyticsMetadata
        }
    }

    @Model
    class Entry {
        var id: String
        var urn: String
        var metadata: EntryMetadata?
        var bookmarkData: Data?
        var progress: Double
        var errorDescription: String?

        init(id: String, urn: String, metadata: EntryMetadata? = nil, bookmarkData: Data? = nil, progress: Double, errorDescription: String? = nil) {
            self.id = id
            self.urn = urn
            self.metadata = metadata
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
                input: .init(urn: urn, server: .production),
                metadata: metadata?.urnMetadata,
                bookmarkData: bookmarkData,
                progress: progress,
                error: DownloadError(errorDescription: errorDescription)
            )
        }

        func update(with record: DownloadRecord<URNAssetLoader.Input, URNMetadata>) {
            self.urn = record.input.urn
            self.metadata = record.metadata?.entryMetadata
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
    static func id(from input: URNAssetLoader.Input) -> String {
        input.id
    }

    static func playerMetadata(from input: URNAssetLoader.Input, metadata: URNMetadata?) -> PlayerMetadata {
        .init(title: metadata?.title ?? input.urn)
    }

    func downloadRecords() -> [DownloadRecord<URNAssetLoader.Input, URNMetadata>] {
        guard let entries = try? context.fetch(FetchDescriptor<Entry>()) else { return [] }
        return entries.map { $0.toRecord() }
    }

    func addDownloadRecord(using input: URNAssetLoader.Input, forId id: String) {
        context.insert(Entry(id: id, urn: input.urn, progress: 0))
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
