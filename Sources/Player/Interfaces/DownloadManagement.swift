//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public protocol DownloadManagement<Store> {
    associatedtype Store: AssetDownloadStore

    var downloads: [Download] { get }

    func addDownload(for input: Store.Input) -> Download

    func download(matching input: Store.Input) -> Download?
    func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<Store.Metadata>]) -> PlayerItem?

    func removeDownload(_ download: Download)
    func removeAllDownloads()
}

#endif
