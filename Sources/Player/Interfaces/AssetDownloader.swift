//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

@_spi(DownloaderPrivate)
public protocol AssetDownloader {
    associatedtype Loader: AssetLoader
    associatedtype Identifier

    func identifier(for input: Loader.Input) -> Identifier

    func download(for identifier: Identifier) -> DownloadData<Loader.Input, Loader.Metadata>?
    func downloads() -> [DownloadData<Loader.Input, Loader.Metadata>]

    func addDownload(using input: Loader.Input, for identifier: Identifier) -> DownloadData<Loader.Input, Loader.Metadata>
    func removeDownload(for identifier: Identifier)

    func updateDownload(metadata: Loader.Metadata, for identifier: Identifier)
}

extension AssetDownloader {
    func download(for input: Loader.Input) -> DownloadData<Loader.Input, Loader.Metadata>? {
        download(for: identifier(for: input))
    }
}

#endif

// swiftlint:enable missing_docs
