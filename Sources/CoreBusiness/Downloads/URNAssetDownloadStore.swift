//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import SwiftData

// swiftlint:disable missing_docs

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
public final class URNAssetDownloadStore {
    let context: ModelContext

    public init() {
        let schema = Schema([Entry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        self.context = .init(try! ModelContainer(for: schema, configurations: [modelConfiguration]))
    }
}

@available(iOS 17.0, *)
extension URNAssetDownloadStore {
    @Model
    class EntryMetadata {
        var identifier: String?
        var title: String?
        var subtitle: String?

        init(identifier: String? = nil, title: String? = nil, subtitle: String? = nil) {
            self.identifier = identifier
            self.title = title
            self.subtitle = subtitle
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

        func toRecord() -> DownloadRecord<URNAssetLoader.Input, MediaMetadata> {
            .init(
                input: .init(urn: urn, server: .production, configuration: .default),
                metadata: nil,
                bookmarkData: bookmarkData,
                progress: progress,
                error: DownloadError(errorDescription: errorDescription)
            )
        }

        func update(with record: DownloadRecord<URNAssetLoader.Input, MediaMetadata>) {
            self.urn = record.input.urn
            self.bookmarkData = record.bookmarkData
            self.progress = record.progress
            self.errorDescription = record.error?.localizedDescription
        }
    }
}

@_spi(DownloaderPrivate)
@available(iOS 17.0, *)
extension URNAssetDownloadStore: AssetDownloadStore {
    public static func id(from input: URNAssetLoader.Input) -> String {
        input.urn
    }

    public func downloadRecords() -> [DownloadRecord<URNAssetLoader.Input, MediaMetadata>] {
        guard let entries = try? context.fetch(FetchDescriptor<Entry>()) else { return [] }
        return entries.map { $0.toRecord() }
    }

    public func addDownloadRecord(using input: URNAssetLoader.Input, forId id: String) {
        context.insert(Entry(id: id, urn: input.urn, progress: 0))
    }

    public func removeDownloadRecord(forId id: String) {
        try? context.delete(model: Entry.self, where: Entry.predicate(for: id))
    }

    public func downloadRecord(forId id: String) -> DownloadRecord<URNAssetLoader.Input, MediaMetadata>? {
        entry(forId: id)?.toRecord()
    }

    public func updateDownloadRecord(_ record: DownloadRecord<URNAssetLoader.Input, MediaMetadata>, forId id: String) {
        guard let entry = entry(forId: id) else { return }
        entry.update(with: record)
        try? context.save()
    }

    private func entry(forId id: String) -> Entry? {
        let descriptor = FetchDescriptor(predicate: Entry.predicate(for: id))
        return try? context.fetch(descriptor).first
    }
}

// swiftlint:enable missing_docs
