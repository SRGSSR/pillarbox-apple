//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol DownloadManagement<Store> {
    associatedtype Store: AssetDownloadStore

    func add(input: Store.Input) -> Download
    func download(matching input: Store.Input) -> Download?
    func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<Store.Metadata>]) -> PlayerItem?
    func remove(_ download: Download)
    func removeAll()
}
