//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

import Foundation
import OrderedCollections

final class AssetDownloadStoreMock: AssetDownloadStore {
    private var records: OrderedDictionary<String, DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>>

    init(preloadedInputs: [AssetLoaderMock.Input] = []) {
        records = OrderedDictionary(uniqueKeysWithValues: preloadedInputs.map { (Self.id(from: $0), Self.record(from: $0)) })
    }

    static func id(from input: AssetLoaderMock.Input) -> String {
        input.url.absoluteString
    }

    static func record(from input: AssetLoaderMock.Input) -> DownloadRecord<AssetLoaderMock.Input, PlayerMetadata> {
        .init(input: input, metadata: nil, bookmarkData: nil, progress: 0, error: nil)
    }

    static func asset(location: URL, input: AssetLoaderMock.Input, metadata: PlayerMetadata) -> Asset {
        .simple(url: location)
    }

    func downloadRecords() -> [DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>] {
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

    func downloadRecord(forId id: String) -> DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>? {
        assert(Thread.isMainThread)
        return records[id]
    }

    func updateDownloadRecord(_ record: DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>, forId id: String) {
        assert(Thread.isMainThread)
        records[id] = record
    }
}
