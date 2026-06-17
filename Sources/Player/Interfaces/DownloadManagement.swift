//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

@available(tvOS, unavailable)
protocol DownloadManagement<Store> {
    associatedtype Store: AssetDownloadStore

    func addDownload(for input: Store.Loader.Input) -> Download

    func download(matching input: Store.Loader.Input) -> Download?
    func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<AssetMetadata<Store.CustomData>>]) -> PlayerItem?

    func removeDownload(_ download: Download)
    func removeAllDownloads()
}

#endif
