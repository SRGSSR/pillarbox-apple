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
    // TODO: Remane methods by including Data in the name.
    associatedtype Loader: AssetLoader

    func identifier(for input: Loader.Input) -> String

    func download(for identifier: String) -> DownloadData<Loader.Input, Loader.Metadata>?
    func downloads() -> [DownloadData<Loader.Input, Loader.Metadata>]

    func addDownload(using input: Loader.Input, for identifier: String) -> DownloadData<Loader.Input, Loader.Metadata>
    func removeDownload(for identifier: String)

    func updateDownload(metadata: Loader.Metadata, for identifier: String)
    func updateDownload(bookmarkData: Data, for identifier: String)
}

extension AssetDownloader {
    func download(for input: Loader.Input) -> DownloadData<Loader.Input, Loader.Metadata>? {
        download(for: identifier(for: input))
    }

    func removeDownload(_ download: DownloadData<Loader.Input, Loader.Metadata>) {
        removeDownload(for: identifier(for: download.input))
    }
}

#endif

// swiftlint:enable missing_docs
