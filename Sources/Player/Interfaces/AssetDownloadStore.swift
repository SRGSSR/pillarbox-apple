//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Foundation

@_spi(DownloaderPrivate)
@available(tvOS, unavailable)
public protocol AssetDownloadStore: AnyObject {
    associatedtype Input
    associatedtype Metadata

    static func id(from input: Input) -> String

    static func asset(fileUrl: URL, input: Input, metadata: Metadata) -> Asset
    static func playerMetadata(from input: Input, metadata: Metadata) -> PlayerMetadata

    func downloadRecords() -> [DownloadRecord<Input, Metadata>]

    func addDownloadRecord(using input: Input, forId id: String)
    func removeDownloadRecord(forId id: String)

    func downloadRecord(forId id: String) -> DownloadRecord<Input, Metadata>?
    func updateDownloadRecord(_ record: DownloadRecord<Input, Metadata>, forId id: String)
}

@available(tvOS, unavailable)
public extension AssetDownloadStore {
    static func asset(fileUrl: URL, input: Input, metadata: Metadata) -> Asset {
        .simple(url: fileUrl)
    }
}

@available(tvOS, unavailable)
public extension AssetDownloadStore where Metadata == PlayerMetadata {
    static func playerMetadata(from input: Input, metadata: Metadata) -> PlayerMetadata {
        metadata
    }
}

@available(tvOS, unavailable)
extension AssetDownloadStore {
    func downloadProperties(forId id: String) -> DownloadProperties<Metadata> {
        guard let record = downloadRecord(forId: id) else { return .init() }
        return .init(from: record)
    }
}

#endif

// swiftlint:enable missing_docs
