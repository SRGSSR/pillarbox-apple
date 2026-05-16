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

    func downloadRecords() -> [DownloadRecord<Input, Metadata>]

    func addDownloadRecord(using input: Input) -> DownloadRecord<Input, Metadata>
    func removeDownloadRecord(for identifier: String)

    func downloadRecord(for identifier: String) -> DownloadRecord<Input, Metadata>?
    func updateDownloadRecord(_ record: DownloadRecord<Input, Metadata>)
}

extension AssetDownloadStore {
    func downloadProperties(for identifier: String) -> DownloadProperties<Metadata> {
        guard let record = downloadRecord(for: identifier) else { return .init() }
        return .init(from: record)
    }
}

#endif

// swiftlint:enable missing_docs
