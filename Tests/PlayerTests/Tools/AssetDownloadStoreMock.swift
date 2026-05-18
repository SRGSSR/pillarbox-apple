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

    static func asset(location: URL, input: AssetLoaderMock.Input, metadata: PlayerMetadata) -> Asset<PlayerMetadata> {
        .simple(url: location, metadata: metadata)
    }

    static func playerMetadata(from metadata: PlayerMetadata) -> PlayerMetadata {
        metadata
    }

    func downloadRecords() -> [DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>] {
        records
    }

    func addDownloadRecord(using input: AssetLoaderMock.Input) -> DownloadRecord<AssetLoaderMock.Input, PlayerMetadata> {
        let record = DownloadRecord(id: input.url.absoluteString, input: input, metadata: input.metadata, bookmarkData: nil, error: nil)
        records.append(record)
        return record
    }

    func removeDownloadRecord(for identifier: String) {
        records.removeAll { $0.id == identifier }
    }

    func downloadRecord(for identifier: String) -> DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>? {
        records.first { $0.id == identifier }
    }

    func updateDownloadRecord(_ record: DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        records[index] = record
    }
}
