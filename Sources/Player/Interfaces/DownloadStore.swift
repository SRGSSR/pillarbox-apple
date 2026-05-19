//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Foundation

@_spi(DownloaderPrivate)
public protocol DownloadStore: AnyObject {
    associatedtype Input
    associatedtype Metadata

    static func asset(fileUrl: URL, input: Input, metadata: Metadata) -> Asset
    static func playerMetadata(from metadata: Metadata) -> PlayerMetadata

    func downloadRecords() -> [DownloadRecord<Input, Metadata>]

    func addDownloadRecord(using input: Input) -> DownloadRecord<Input, Metadata>
    func removeDownloadRecord(forId id: String)

    func downloadRecord(forId id: String) -> DownloadRecord<Input, Metadata>?
    func updateDownloadRecord(_ record: DownloadRecord<Input, Metadata>)
}

public extension DownloadStore where Metadata == PlayerMetadata {
    static func playerMetadata(from metadata: Metadata) -> PlayerMetadata {
        metadata
    }
}

extension DownloadStore {
    func downloadProperties(forId id: String) -> DownloadProperties<Metadata> {
        guard let record = downloadRecord(forId: id) else { return .init() }
        return .init(from: record)
    }
}

#endif

// swiftlint:enable missing_docs
