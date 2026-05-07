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

    func identifier(for input: Input) -> String

    func downloadRecord(for identifier: String) -> DownloadRecord<Input, Metadata>?
    func downloadRecords() -> [DownloadRecord<Input, Metadata>]

    func addDownloadRecord(using input: Input, for identifier: String) -> DownloadRecord<Input, Metadata>
    func removeDownloadRecord(for identifier: String)

    func updateDownloadRecord(metadata: Metadata, for identifier: String)
    func updateDownloadRecord(bookmarkData: Data, for identifier: String)
}

extension AssetDownloadStore {
    func downloadRecord(for input: Input) -> DownloadRecord<Input, Metadata>? {
        downloadRecord(for: identifier(for: input))
    }

    func removeDownloadRecord(_ download: DownloadRecord<Input, Metadata>) {
        removeDownloadRecord(for: identifier(for: download.input))
    }
}

#endif

// swiftlint:enable missing_docs
