//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

import Foundation
import OrderedCollections

@available(tvOS, unavailable)
final class AssetDownloadStoreMock {
    private var records: OrderedDictionary<String, DownloadRecord<AssetLoaderMockInput, Void>>

    init(preloadedInputs: [AssetLoaderMockInput] = []) {
        records = preloadedInputs.reduce(into: [:]) { records, input in
            records.updateValue(Self.record(from: input), forKey: Self.id(from: input))
        }
    }
}

@available(tvOS, unavailable)
extension AssetDownloadStoreMock: AssetDownloadStore {
    typealias Loader = AssetLoaderMock

    static func id(from input: AssetLoaderMockInput) -> String {
        input.id
    }

    static func customData(from metadata: PlayerMetadata) {}

    static func record(from input: AssetLoaderMockInput) -> DownloadRecord<AssetLoaderMockInput, Void> {
        .init(input: input, metadata: nil, bookmarkData: nil, progress: 0, error: nil)
    }

    func downloadRecords() -> [DownloadRecord<AssetLoaderMockInput, Void>] {
        assert(Thread.isMainThread)
        return Array(records.values)
    }

    func addDownloadRecord(using input: AssetLoaderMockInput, forId id: String) {
        assert(Thread.isMainThread)
        records[id] = Self.record(from: input)
    }

    func removeDownloadRecord(forId id: String) {
        assert(Thread.isMainThread)
        records.removeValue(forKey: id)
    }

    func downloadRecord(forId id: String) -> DownloadRecord<AssetLoaderMockInput, Void>? {
        assert(Thread.isMainThread)
        return records[id]
    }

    func updateDownloadRecord(_ record: DownloadRecord<AssetLoaderMockInput, Void>, forId id: String) {
        assert(Thread.isMainThread)
        records[id] = record
    }
}
