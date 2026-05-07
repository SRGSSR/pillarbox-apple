//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Foundation

@_spi(DownloaderPrivate)
public protocol AssetDownloader: AnyObject {
    associatedtype Input
    associatedtype Metadata

    func identifier(for input: Input) -> String

    func download(for identifier: String) -> DownloadData<Input, Metadata>?
    func downloads() -> [DownloadData<Input, Metadata>]

    func addDownload(using input: Input, for identifier: String) -> DownloadData<Input, Metadata>
    func removeDownload(for identifier: String)

    func updateDownload(metadata: Metadata, for identifier: String)
    func updateDownload(bookmarkData: Data, for identifier: String)
}

extension AssetDownloader {
    func download(for input: Input) -> DownloadData<Input, Metadata>? {
        download(for: identifier(for: input))
    }

    func removeDownload(_ download: DownloadData<Input, Metadata>) {
        removeDownload(for: identifier(for: download.input))
    }
}

#endif

// swiftlint:enable missing_docs
