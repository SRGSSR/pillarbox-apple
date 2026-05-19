//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

import Foundation

final class AssetDownloadStoreMock: AssetDownloadStore {
    private var records: [DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>] = []

    static func asset(fileUrl: URL, input: AssetLoaderMock.Input, metadata: PlayerMetadata) -> Asset {
        .simple(url: fileUrl)
    }

    func downloadRecords() -> [DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>] {
        records
    }

    func addDownloadRecord(using input: AssetLoaderMock.Input) -> DownloadRecord<AssetLoaderMock.Input, PlayerMetadata> {
        let record = DownloadRecord(id: input.url.absoluteString, input: input, metadata: input.metadata, bookmarkData: nil, error: nil)
        records.append(record)
        return record
    }

    func removeDownloadRecord(forId id: String) {
        records.removeAll { $0.id == id }
    }

    func downloadRecord(forId id: String) -> DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>? {
        records.first { $0.id == id }
    }

    func updateDownloadRecord(_ record: DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        records[index] = record
    }
}
