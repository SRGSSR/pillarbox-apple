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
final class DownloadManager<L, S>: NSObject, AVAssetDownloadDelegate where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
    private let store: S
    private var session: AVAssetDownloadURLSession!

    @Published private(set) var downloads: [Download<L>] = []

    init(loaderType: L.Type, store: S) {
        self.store = store
        super.init()
        self.session = .init(
            configuration: .background(withIdentifier: "ch.srgssr.player.downloader"), // TODO: We should better handle the identifier.
            assetDownloadDelegate: self,
            delegateQueue: .main
        )
        self.downloads = store.downloadRecords().map { record in
            let id = store.identifier(for: record.input)
            return Download(id: id, loaderType: loaderType, record: record, session: session, delegate: self)
        }
    }

    @discardableResult
    func add(input: S.Input) -> Download<L> {
        let id = store.identifier(for: input)
        if let download = download(with: id) {
            return download
        }
        else {
            let record = store.addDownloadRecord(using: input, for: id)
            let download = Download(id: id, loaderType: L.self, record: record, session: session, delegate: self)
            downloads.append(download)
            return download
        }
    }

    private func download(with id: String) -> Download<L>? {
        downloads.first { $0.id == id }
    }

    func remove(_ download: Download<L>) {
        download.cancel()
        store.removeDownloadRecord(for: download.id)
        downloads.removeAll { $0.id == download.id }
    }

    func removeAll() {
        downloads.forEach { download in
            download.cancel()
            store.removeDownloadRecord(for: download.id)
        }
        downloads.removeAll()
    }

    // MARK: AVAssetDownloadDelegate

#if os(iOS)
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
        guard let download = download(matching: assetDownloadTask) else { return }
        download.attach(to: location)
    }
#endif

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let download = download(matching: task) else { return }
        download.complete(with: error)
    }

    private func download(matching task: URLSessionTask) -> Download<L>? {
        downloads.first { $0.matches(task: task) }
    }
}

extension DownloadManager: DownloadDelegate {
    func didProvideMetadata(_ metadata: L.Metadata, for identifier: String) {
        store.updateDownloadRecord(metadata: metadata, for: identifier)
    }

    func didProvideBookmarkData(_ bookmarkData: Data, for identifier: String) {
        store.updateDownloadRecord(bookmarkData: bookmarkData, for: identifier)
    }
}

#endif
