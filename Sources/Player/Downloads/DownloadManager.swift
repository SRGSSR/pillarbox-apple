//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@available(tvOS, unavailable)
protocol DownloadManager<Input, CustomData> {
    associatedtype Input
    associatedtype CustomData

    func addDownload(for input: Input, configuration: DownloadConfiguration) -> Download
    func download(matching input: Input) -> Download?

    func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<AssetMetadata<CustomData>>]) -> PlayerItem?

    func removeDownload(_ download: Download)
    func removeAllDownloads()
}
