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
    private var records: OrderedDictionary<String, DownloadRecord<AssetLoaderMock.Input, Void>>

    init(preloadedInputs: [AssetLoaderMock.Input] = []) {
        records = preloadedInputs.reduce(into: [:]) { records, input in
            records.updateValue(Self.record(from: input), forKey: Self.id(from: input))
        }
    }
}

@available(tvOS, unavailable)
extension AssetDownloadStoreMock: AssetDownloadStore {
    typealias Loader = AssetLoaderMock

    static func id(from input: AssetLoaderMock.Input) -> String {
        input.id
    }

    static func customData(from metadata: PlayerMetadata) {}

    static func record(from input: AssetLoaderMock.Input) -> DownloadRecord<AssetLoaderMock.Input, Void> {
        .init(
            input: input,
            metadata: .init(playerMetadata: input.metadata, customData: ()),
            bookmarkData: nil,
            progress: 0,
            error: nil
        )
    }

    func downloadRecords() -> [DownloadRecord<AssetLoaderMock.Input, Void>] {
        assert(Thread.isMainThread)
        return Array(records.values)
    }

    func addDownloadRecord(using input: AssetLoaderMock.Input, forId id: String) {
        assert(Thread.isMainThread)
        records[id] = Self.record(from: input)
    }

    func removeDownloadRecord(forId id: String) {
        assert(Thread.isMainThread)
        records.removeValue(forKey: id)
    }

    func downloadRecord(forId id: String) -> DownloadRecord<AssetLoaderMock.Input, Void>? {
        assert(Thread.isMainThread)
        return records[id]
    }

    func updateDownloadRecord(_ record: DownloadRecord<AssetLoaderMock.Input, Void>, forId id: String) {
        assert(Thread.isMainThread)
        records[id] = record
    }
}
