//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import SwiftData

@_spi(DownloaderPrivate)
import PillarboxPlayer

@available(iOS 17.0, *)
@available(tvOS, unavailable)
final class URNAssetDownloadStore {
    typealias URNEntry = URNSchemaV1.URNEntry

    let context: ModelContext

    init(name: String? = nil) throws {
        let schema = Schema([URNEntry.self])
        let modelConfiguration = ModelConfiguration(name, schema: schema, isStoredInMemoryOnly: false)
        self.context = .init(try ModelContainer(for: schema, configurations: [modelConfiguration]))
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

    static func playerMetadata(from input: URNAssetLoader.Input, metadata: MediaMetadata?) -> PlayerMetadata {
        metadata?.playerMetadata(dateFormat: .standard) ?? .empty
    }

    static func customData(from metadata: MediaMetadata) -> URNMetadata {
        .init(analyticsData: metadata.analyticsData, analyticsMetadata: metadata.analyticsMetadata)
    }

    static func asset(fileUrl: URL, customData: URNMetadata) -> Asset {
        // TODO: Handle Akamai token protection and DRM encryption
        .simple(url: fileUrl)
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
