//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol DownloadManagement<S> {
    associatedtype S: AssetDownloadStore

    func add(input: S.Input) -> Download
    func download(matching input: S.Input) -> Download?
    func playerItem(for download: Download, allowsPartial: Bool, trackerAdapters: [TrackerAdapter<S.Metadata>]) -> PlayerItem?
    func remove(_ download: Download)
    func removeAll()
}
