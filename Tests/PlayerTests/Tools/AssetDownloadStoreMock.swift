//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
@testable import PillarboxPlayer

import Foundation
import OrderedCollections

@available(tvOS, unavailable)
final class AssetDownloadStoreMock {
    private var records: OrderedDictionary<String, DownloadRecord<AssetLoaderMock.Input, EmptyCustomData>>

    init(preloadedInputs: [AssetLoaderMock.Input] = []) {
        records = preloadedInputs.reduce(into: [:]) { records, input in
            records.updateValue(.init(input: input, configuration: .default, creationDate: .now), forKey: Self.id(from: input))
        }
    }
}

@available(tvOS, unavailable)
extension AssetDownloadStoreMock: AssetDownloadStore {
    typealias Loader = AssetLoaderMock

    static func id(from input: AssetLoaderMock.Input) -> String {
        input.id
    }

    static func customData(from metadata: PlayerMetadata) -> EmptyCustomData {
        .init()
    }

    static func asset(fileUrl: URL, customData: EmptyCustomData) -> Asset {
        // TODO: Configuration
        .simple(url: fileUrl)
    }

    func downloadRecords() -> [DownloadRecord<AssetLoaderMock.Input, EmptyCustomData>] {
        assert(Thread.isMainThread)
        return Array(records.values)
    }

    func addDownloadRecord(_ record: DownloadRecord<AssetLoaderMock.Input, EmptyCustomData>, forId id: String) {
        assert(Thread.isMainThread)
        records[id] = record
    }

    func removeDownloadRecord(forId id: String) {
        assert(Thread.isMainThread)
        records.removeValue(forKey: id)
    }

    func downloadRecord(forId id: String) -> DownloadRecord<AssetLoaderMock.Input, EmptyCustomData>? {
        assert(Thread.isMainThread)
        return records[id]
    }

    func updateDownloadRecord(_ record: DownloadRecord<AssetLoaderMock.Input, EmptyCustomData>, forId id: String) {
        assert(Thread.isMainThread)
        records[id] = record
    }
}
