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
    private var records: OrderedDictionary<String, DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>> = [:]

    static func id(from input: AssetLoaderMock.Input) -> String {
        input.url.absoluteString
    }

    static func asset(fileUrl: URL, input: AssetLoaderMock.Input, metadata: PlayerMetadata) -> Asset {
        .simple(url: fileUrl)
    }

    func downloadRecords() -> [DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>] {
        Array(records.values)
    }

    func addDownloadRecord(using input: AssetLoaderMock.Input, forId id: String) {
        let record = DownloadRecord(input: input, metadata: input.metadata, bookmarkData: nil, error: nil)
        records[id] = record
    }

    func removeDownloadRecord(forId id: String) {
        records.removeValue(forKey: id)
    }

    func downloadRecord(forId id: String) -> DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>? {
        records[id]
    }

    func updateDownloadRecord(_ record: DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>, forId id: String) {
        records[id] = record
    }
}
