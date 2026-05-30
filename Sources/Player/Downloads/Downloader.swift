//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import Combine
import Foundation

#if DEBUG

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Downloader<S>: ObservableObject where S: AssetDownloadStore {
    private let manager: any DownloadManagement<S>

    @Published public private(set) var downloads: [Download] = []

    public init<L>(
        assetLoaderType: L.Type,
        configuration: URLSessionConfiguration,
        store: S
    ) where L: AssetLoader, L.Input == S.Input, L.Metadata == S.Metadata {
        let manager = DownloadManager(assetLoaderType: assetLoaderType, session: URLDownloadSession(configuration: configuration), store: store)
        self.manager = manager

        manager.$downloads
            .assign(to: &$downloads)
    }

    @discardableResult
    public func addDownload(for input: S.Input) -> Download {
        manager.addDownload(for: input)
    }

    public func download(matching input: S.Input) -> Download? {
        manager.download(matching: input)
    }

    public func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<S.Metadata>] = []) -> PlayerItem? {
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
