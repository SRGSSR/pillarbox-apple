//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

import Foundation

final class AssetDownloadStoreMock: AssetDownloadStore {
    struct StoreRecord<Input> {
        let id: String
        let input: Input
        let metadata: PlayerMetadata

        func toDownloadRecord() -> DownloadRecord<Input, PlayerMetadata> {
            .init(input: input, metadata: metadata, bookmarkData: nil)
        }

        func withMetadata(_ metadata: PlayerMetadata) -> Self {
            .init(id: id, input: input, metadata: metadata)
        }
    }

    private var records: [StoreRecord<AssetLoaderMock.Input>] = []

    func identifier(for input: AssetLoaderMock.Input) -> String {
        input.url.absoluteString
    }

    func downloadRecord(for identifier: String) -> DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>? {
        records.first { $0.id == identifier }
            .map { $0.toDownloadRecord() }
    }

    func downloadRecords() -> [DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>] {
        records.map { $0.toDownloadRecord() }
    }

    func addDownloadRecord(using input: AssetLoaderMock.Input, for identifier: String) -> DownloadRecord<AssetLoaderMock.Input, PlayerMetadata> {
        let record = StoreRecord(id: identifier, input: input, metadata: input.metadata)
        records.append(record)
        return record.toDownloadRecord()
    }

    func removeDownloadRecord(for identifier: String) {
        records.removeAll { $0.id == identifier }
    }

    func updateDownloadRecord(metadata: PlayerMetadata, for identifier: String) {
        guard let index = records.firstIndex(where: { $0.id == identifier }) else { return }
        records[index] = records[index].withMetadata(metadata)
    }

    func updateDownloadRecord(bookmarkData: Data, for identifier: String) {}
}
