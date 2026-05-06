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
final class DownloadManager<A>: NSObject, AVAssetDownloadDelegate where A: AssetDownloader {
    private lazy var session = AVAssetDownloadURLSession(
        configuration: .background(withIdentifier: "ch.srgssr.player.downloader"), // TODO: We should better handle the identifier.
        assetDownloadDelegate: self,
        delegateQueue: .main
    )

    @Published private(set) var downloads: [Download<A>] = []
    private let downloader: A

    init(downloader: A) {
        self.downloader = downloader
        super.init()
        restore()
    }

    @discardableResult
    func add(input: A.Loader.Input) -> Download<A> {
        let download = Download(from: input, downloader: downloader, using: session)
        // TODO: We should probably insert the download here.
        downloads.append(download)
        return download
    }

    func remove(_ download: Download<A>) {
        download.cancel() // <----
        downloader.removeDownload(download.data) // ---> // TODO: Should we move this in Download to avoid duplication with remove all?
        downloads.removeAll { $0 == download }
    }

    func removeAll() {
        downloads.forEach { download in
            download.cancel()
            downloader.removeDownload(download.data)
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

    private func download(matching task: URLSessionTask) -> Download<A>? {
        downloads.first { $0.matches(task: task) }
    }
}

@available(tvOS, unavailable)
private extension DownloadManager {
    func restoreDownloads(reusing tasks: [URLSessionTask]) -> [Download<A>] {
        downloader.downloads().map { downloadData in
            Download(from: downloadData, downloader: downloader, reusing: tasks, in: session)
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
