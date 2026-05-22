//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import UIKit

#if DEBUG

@available(tvOS, unavailable)
final class DownloadManager<L, S>: DownloadManagement<S> where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
    private let session: any DownloadSession
    private let store: S

    @Published private(set) var downloads: [Download] = []

    init(loaderType: L.Type, session: some DownloadSession, store: S) {
        self.session = session
        self.store = store
        self.downloads = store.downloadRecords().map { record in
            Download(loaderType: loaderType, record: record, session: session, store: store)
        }
        session.delegate = self
    }

    @discardableResult
    func addDownload(input: L.Input) -> Download {
        if let download = download(matching: input) {
            return download
        }
        else {
            let download = Download(loaderType: L.self, input: input, session: session, store: store)
            downloads.append(download)
            return download
        }
    }

    func download(matching input: L.Input) -> Download? {
        let id = type(of: store).id(from: input)
        return downloads.first { $0.id == id }
    }

    func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<L.Metadata>]) -> PlayerItem? {
        guard downloads.contains(download) else { return nil }
        return .init(download: download, store: store, trackerAdapters: trackerAdapters)
    }

    func removeDownload(_ download: Download) {
        guard downloads.contains(download) else { return }
        download.remove()
        downloads.removeAll { $0.id == download.id }
    }

    func removeAllDownloads() {
        downloads.forEach { download in
            download.remove()
        }
        downloads.removeAll()
    }
}

extension DownloadManager: DownloadSessionDelegate {
    func downloadSessionWillDownloadToLocation(_ location: URL, forId id: String) {
        guard let download = download(matchingId: id) else { return }
        download.attach(to: location)
    }

    func downloadSessionDidFailWithError(_ error: any Error, forId id: String) {
        guard let download = download(matchingId: id) else { return }
        download.fail(with: error)
    }

    private func download(matchingId id: String) -> Download? {
        downloads.first { $0.id == id }
    }
}

#endif
