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
    typealias StandardEntry = StandardSchemaV1<Provider.Input, Provider.CustomData>.StandardEntry

    let context: ModelContext

    init(name: String? = nil, providerType: Provider.Type) throws {
        let schema = Schema([StandardEntry.self])
        let modelConfiguration = ModelConfiguration(name, schema: schema, isStoredInMemoryOnly: false)
        self.context = .init(try ModelContainer(for: schema, configurations: [modelConfiguration]))
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
