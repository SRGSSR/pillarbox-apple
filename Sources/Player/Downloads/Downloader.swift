//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import UIKit

#if DEBUG
@_spi(DownloaderPrivate)
public final class Downloader: NSObject, ObservableObject {
    private lazy var session = AVAssetDownloadURLSession(
        configuration: .background(withIdentifier: "ch.srgssr.player.downloader"),
        assetDownloadDelegate: self,
        delegateQueue: .main
    )

    @Published public private(set) var downloads: [Download] = [] {
        didSet {
            Self.saveDownloads(downloads)
        }
    }

    override public init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(terminate), name: UIApplication.willTerminateNotification, object: nil)
        restore()
    }

    @discardableResult
    public func add(title: String, url: URL) -> Download {
        let download = Download.create(title: title, url: url, using: session)
        downloads.append(download)
        download.resume()
        return download
    }

    public func remove(_ download: Download) {
        download.cancel()
        downloads.removeAll { $0 == download }
    }

    @objc
    private func terminate() {
        Self.saveDownloads(downloads)
    }
}

private extension Downloader {
    private static let metadataFileUrl = URL.libraryDirectory.appending(component: "downloads.json")

    static func restoreDownloads(reusing tasks: [URLSessionTask], in session: AVAssetDownloadURLSession) -> [Download] {
        guard let jsonData = try? Data(contentsOf: metadataFileUrl),
              let metadata = try? JSONDecoder().decode([DownloadMetadata].self, from: jsonData) else {
            return []
        }
        return metadata.map { metadata in
            let download = Download.restore(from: metadata, reusing: tasks, in: session)
            download.resume()
            return download
        }
    }

    static func saveDownloads(_ downloads: [Download]) {
        let metadata = downloads.map { $0.metadata() }
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

extension Downloader: AVAssetDownloadDelegate {
    public func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
        guard let download = download(matching: assetDownloadTask) else { return }
        download.attach(to: location)
    }

    private func download(matching task: URLSessionTask) -> Download? {
        downloads.first { $0.matches(task: task) }
    }
}

#endif
