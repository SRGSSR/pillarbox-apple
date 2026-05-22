//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@available(tvOS, unavailable)
protocol DownloadManagement<Store> {
    associatedtype Store: AssetDownloadStore

    func addDownload(input: Store.Input) -> Download

    func download(matching input: Store.Input) -> Download?
    func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<Store.Metadata>]) -> PlayerItem?

    func removeDownload(_ download: Download)
    func removeAllDownloads()
}
