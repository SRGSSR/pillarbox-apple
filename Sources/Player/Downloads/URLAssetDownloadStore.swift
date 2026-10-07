//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import SwiftData

@available(iOS 17.0, *)
@available(tvOS, unavailable)
final class URLAssetDownloadStore<Provider> where Provider: URLAssetDownloadStoreProvider {
    typealias URLEntry = URLSchemaV1<Provider.CustomData>.URLEntry

    let context: ModelContext

    init(name: String? = nil, providerType: Provider.Type) throws {
        let schema = Schema([URLEntry.self])
        let modelConfiguration = ModelConfiguration(name, schema: schema, isStoredInMemoryOnly: false)
        self.context = .init(try ModelContainer(for: schema, configurations: [modelConfiguration]))
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
extension URLAssetDownloadStore: AssetDownloadStore {
    typealias Loader = URLAssetLoader<Provider>

    static func id(from input: URLInput<CustomData>) -> String {
        input.url.absoluteString
    }

    static func customData(from metadata: AssetMetadata<Provider.CustomData>) -> Provider.CustomData {
        metadata.customData
    }

    static func asset(fileUrl: URL, customData: Provider.CustomData) -> Asset {
        Provider.asset(fileUrl: fileUrl, customData: customData)
    }

    func downloadRecords() -> [DownloadRecord<URLInput<CustomData>, Provider.CustomData>] {
        guard let entries = try? context.fetch(FetchDescriptor<URLEntry>()) else { return [] }
        return entries.map { $0.toRecord() }
    }

    func addDownloadRecord(_ record: DownloadRecord<URLInput<CustomData>, Provider.CustomData>, forId id: String) {
        context.insert(URLEntry(id: id, record: record))
    }

    func removeDownloadRecord(forId id: String) {
        try? context.delete(model: URLEntry.self, where: URLEntry.predicate(for: id))
    }

    func downloadRecord(forId id: String) -> DownloadRecord<URLInput<CustomData>, Provider.CustomData>? {
        entry(forId: id)?.toRecord()
    }

    func updateDownloadRecord(_ record: DownloadRecord<URLInput<CustomData>, Provider.CustomData>, forId id: String) {
        guard let entry = entry(forId: id) else { return }
        entry.update(with: record)
        try? context.save()
    }

    private func entry(forId id: String) -> URLEntry? {
        let descriptor = FetchDescriptor(predicate: URLEntry.predicate(for: id))
        return try? context.fetch(descriptor).first
    }
}
