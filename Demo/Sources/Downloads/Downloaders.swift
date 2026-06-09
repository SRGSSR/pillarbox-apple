//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

@_spi(DownloaderPrivate)
import PillarboxPlayer

@_spi(DownloaderPrivate)
import PillarboxCoreBusiness

final class Downloaders: ObservableObject {
    private let downloaders: [any DownloadManagement]

    var downloads: [Download] {
        downloaders.reduce([]) { total, increment in
            total + increment.downloads
        }
    }

    init(downloaders: [any DownloadManagement]) {
        self.downloaders = downloaders
    }

    func addDownload<S>(ofType type: S.Type, input: S.Input) -> Download? where S: AssetDownloadStore {
        downloader(ofType: type)?.addDownload(for: input)
    }

    func playerItem(for download: Download) -> PlayerItem? {
        if let download = downloader(ofType: DemoAssetDownloadStore.self)?.playerItem(for: download, trackerAdapters: []) {
            return download
        }
        else if #available(iOS 17, *), let download = downloader(ofType: URNAssetDownloadStore.self)?.playerItem(for: download, trackerAdapters: []) {
            return download
        }
        else {
            return nil
        }
    }

    func removeDownload(_ download: Download) {
        objectWillChange.send()
        downloaders.forEach { downloader in
            downloader.removeDownload(download)
        }
    }

    func removeAllDownloads() {
        objectWillChange.send()
        downloaders.forEach { downloader in
            downloader.removeAllDownloads()
        }
    }

    private func downloader<S>(ofType type: S.Type) -> (any DownloadManagement<S>)? {
        for downloader in downloaders {
            guard let typedDownloader = downloader as? any DownloadManagement<S> else { continue }
            return typedDownloader
        }
        return nil
    }
}
