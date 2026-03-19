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
final class DownloadManager: NSObject {
    private lazy var session = AVAssetDownloadURLSession(
        configuration: .background(withIdentifier: "ch.srgssr.player.downloader"),
        assetDownloadDelegate: self,
        delegateQueue: .main
    )

    @Published private(set) var downloads: [Download] = [] {
        didSet {
            Self.saveDownloads(downloads)
        }
    }

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateDownload(_:)), name: .didUpdateDownload, object: nil)
        restore()
    }

    @discardableResult
    func add<P, M>(publisher: P, metadataMapper: @escaping (M) -> PlayerMetadata) -> Download where P: Publisher, P.Output == Asset<M> {
        add(download: Download(publisher: publisher, metadataMapper: metadataMapper, using: session))
    }

    @discardableResult
    func add<M>(asset: Asset<M>) -> Download where M: AssetMetadata {
        add(download: Download(asset: asset, using: session))
    }

    private func add(download: Download) -> Download {
        downloads.append(download)
        return download
    }

    func remove(_ download: Download) {
        download.cancel()
        downloads.removeAll { $0 == download }
    }

    func removeAll() {
        downloads.forEach { download in
            download.cancel()
        }
        downloads.removeAll()
    }

    @objc
    private func didUpdateDownload(_ notification: Notification) {
        guard let download = notification.object as? Download, downloads.contains(download) else { return }
        Self.saveDownloads(downloads)
    }
}

@available(tvOS, unavailable)
private extension DownloadManager {
    private static let metadataFileUrl = URL.libraryDirectory.appending(component: "downloads.json")

    static func restoreDownloads(reusing tasks: [URLSessionTask], in session: AVAssetDownloadURLSession) -> [Download] {
        guard let jsonData = try? Data(contentsOf: metadataFileUrl),
              let metadata = try? JSONDecoder().decode([DownloadMetadata].self, from: jsonData) else {
            return []
        }
        return []
        // FIXME return metadata.map { Download(from: $0, reusing: tasks, in: session) }
    }

    static func saveDownloads(_ downloads: [Download]) {
        let metadata = downloads.map { $0.downloadMetadata() }
        guard let jsonData = try? JSONEncoder().encode(metadata) else { return }
        try? jsonData.write(to: metadataFileUrl)
    }

    func restore() {
        session.getAllTasks { [weak self] tasks in
            guard let self else { return }
            downloads = Self.restoreDownloads(reusing: tasks, in: session)
        }
    }
}

@available(tvOS, unavailable)
extension DownloadManager: AVAssetDownloadDelegate {
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

    private func download(matching task: URLSessionTask) -> Download? {
        downloads.first { $0.matches(task: task) }
    }
}

#endif
