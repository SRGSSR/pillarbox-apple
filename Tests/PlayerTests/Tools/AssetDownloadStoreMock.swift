//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

import Foundation

final class AssetDownloadStoreMock: AssetDownloadStore {
    struct StoreItem<Input> {
        let id: String
        let record: DownloadRecord<Input, PlayerMetadata>

        init(id: String, record: DownloadRecord<Input, PlayerMetadata>) {
            self.id = id
            self.record = record
        }

        init(id: String, input: Input, metadata: PlayerMetadata) {
            self.id = id
            self.record = .init(input: input, metadata: metadata, bookmarkData: nil, error: nil)
        }
    }

    private var records: [StoreItem<AssetLoaderMock.Input>] = []

    func identifier(for input: AssetLoaderMock.Input) -> String {
        input.url.absoluteString
    }

    func downloadRecord(for identifier: String) -> DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>? {
        records.first { $0.id == identifier }.map(\.record)
    }

    func downloadRecords() -> [DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>] {
        records.map(\.record)
    }

    func addDownloadRecord(using input: AssetLoaderMock.Input, for identifier: String) -> DownloadRecord<AssetLoaderMock.Input, PlayerMetadata> {
        let item = StoreItem(id: identifier, input: input, metadata: input.metadata)
        records.append(item)
        return item.record
    }

    func removeDownloadRecord(for identifier: String) {
        records.removeAll { $0.id == identifier }
    }

    func updateDownloadRecord(_ record: DownloadRecord<AssetLoaderMock.Input, PlayerMetadata>, for identifier: String) {
        guard let index = records.firstIndex(where: { $0.id == identifier }) else { return }
        records[index] = .init(id: identifier, record: record)
    }
}
