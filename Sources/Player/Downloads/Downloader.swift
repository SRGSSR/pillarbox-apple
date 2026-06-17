//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Combine
import Foundation

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Downloader<S>: ObservableObject where S: AssetDownloadStore {
    private let manager: any DownloadManagement<S>

    @Published public private(set) var downloads: [Download] = []

    public init<L>(
        assetLoaderType: L.Type,
        configuration: URLSessionConfiguration,
        store: S
    ) where L: AssetLoader, L == S.Loader {
        let manager = DownloadManager(
            assetLoaderType: assetLoaderType,
            store: store,
            session: URLDownloadSession(configuration: configuration)
        )
        self.manager = manager

        manager.$downloads
            .assign(to: &$downloads)
    }

    @discardableResult
    public func addDownload(for input: S.Loader.Input) -> Download {
        manager.addDownload(for: input)
    }

    public func download(matching input: S.Loader.Input) -> Download? {
        manager.download(matching: input)
    }

    public func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<S.CustomData>] = []) -> PlayerItem? {
        manager.playerItem(for: download, trackerAdapters: trackerAdapters)
    }

    public func removeDownload(_ download: Download) {
        manager.removeDownload(download)
    }

    public func removeAllDownloads() {
        manager.removeAllDownloads()
    }
}

#endif

// swiftlint:enable missing_docs
