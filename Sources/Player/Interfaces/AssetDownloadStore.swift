//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Foundation

@_spi(DownloaderPrivate)
public protocol AssetDownloadStore: AnyObject {
    associatedtype Input
    associatedtype Metadata

    static func id(from input: Input) -> String

    static func asset(location: URL, input: Input, metadata: Metadata) -> Asset
    static func playerMetadata(from metadata: Metadata) -> PlayerMetadata

    func downloadRecords() -> [DownloadRecord<Input, Metadata>]

    func addDownloadRecord(using input: Input, forId id: String)
    func removeDownloadRecord(forId id: String)

    // TODO: Could have a removeAll with default implementation

    func downloadRecord(forId id: String) -> DownloadRecord<Input, Metadata>?
    func updateDownloadRecord(_ record: DownloadRecord<Input, Metadata>, forId id: String)
}

public extension AssetDownloadStore where Metadata == PlayerMetadata {
    static func playerMetadata(from metadata: Metadata) -> PlayerMetadata {
        metadata
    }
}

extension AssetDownloadStore {
    func downloadProperties(forId id: String) -> DownloadProperties<Metadata> {
        guard let record = downloadRecord(forId: id) else { return .init() }
        return .init(from: record)
    }
}

#endif

// swiftlint:enable missing_docs
