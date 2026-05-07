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
    private lazy var session = AVAssetDownloadURLSession(
        configuration: .background(withIdentifier: "ch.srgssr.player.downloader"), // TODO: We should better handle the identifier.
        assetDownloadDelegate: self,
        delegateQueue: .main
    )

    @Published private(set) var downloads: [Download<L, S>] = []
    private let store: S

    init(store: S) {
        self.store = store
        super.init()
        restore()
    }

    @discardableResult
    func add(input: S.Input) -> Download<L, S> {
        let download = Download(loaderType: L.self, from: input, store: store, using: session)
        // TODO: We should probably insert the download here.
        downloads.append(download)
        return download
    }

    func remove(_ download: Download<L, S>) {
        download.cancel() // <----
        store.removeDownloadRecord(download.record) // ---> // TODO: Should we move this in Download to avoid duplication with remove all?
        downloads.removeAll { $0 == download }
    }

    func removeAll() {
        downloads.forEach { download in
            download.cancel()
            store.removeDownloadRecord(download.record)
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

    private func download(matching task: URLSessionTask) -> Download<L, S>? {
        downloads.first { $0.matches(task: task) }
    }
}

@available(tvOS, unavailable)
private extension DownloadManager {
    func restoreDownloads(reusing tasks: [URLSessionTask]) -> [Download<L, S>] {
        store.downloadRecords().map { downloadRecord in
            Download(loaderType: L.self, from: downloadRecord, store: store, reusing: tasks, in: session)
        }
    }

    func restore() {
        session.getAllTasks { [weak self] tasks in
            guard let self else { return }
            downloads = restoreDownloads(reusing: tasks)
        }
    }
}

#endif
