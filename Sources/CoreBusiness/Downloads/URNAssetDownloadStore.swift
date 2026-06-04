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
    class Entry {
        var id: String
        var urn: String
        var bookmarkData: Data?
        var progress: Double
        var errorDescription: String?

        init(id: String, urn: String, bookmarkData: Data? = nil, progress: Double, errorDescription: String? = nil) {
            self.id = id
            self.urn = urn
            self.bookmarkData = bookmarkData
            self.progress = progress
            self.errorDescription = errorDescription
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

    public func removeDownloadRecord(forId id: String) {}

    public func downloadRecord(forId id: String) -> DownloadRecord<URNAssetLoader.Input, MediaMetadata>? {
        nil
    }

    public func updateDownloadRecord(_ record: DownloadRecord<URNAssetLoader.Input, MediaMetadata>, forId id: String) {}
}

// swiftlint:enable missing_docs
