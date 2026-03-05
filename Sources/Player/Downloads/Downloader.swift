//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import OrderedCollections

private enum Location {
    case empty
    case fileUrl(URL)
}

#if DEBUG
@_spi(DownloaderPrivate)
public final class Downloader: NSObject, ObservableObject {
    @Published private var _downloads: OrderedDictionary<Download, Location> = [:]

    private lazy var session = AVAssetDownloadURLSession(
        configuration: .background(withIdentifier: "ch.srgssr.player.downloader"),
        assetDownloadDelegate: self,
        delegateQueue: .main
    )

    public var downloads: [Download] {
        Array(_downloads.keys)
    }

    override public init() {
        super.init()
        restore()
    }

    @discardableResult
    public func add(title: String, url: URL) -> Download {
        let download = Download(task: downloadTask(title: title, url: url))
        download.resume()
        _downloads[download] = .empty
        return download
    }

    public func remove(_ download: Download) {
        download.cancel()
        removeFile(for: download)
        _downloads.removeValue(forKey: download)
    }

    public func fileUrl(for download: Download) -> URL? {
        if let location = _downloads[download], case let .fileUrl(fileUrl) = location {
            return fileUrl
        }
        else {
            return nil
        }
    }

    private func removeFile(for download: Download) {
        guard let fileUrl = fileUrl(for: download) else { return }
        try? FileManager.default.removeItem(at: fileUrl)
    }

    private func downloadTask(title: String, url: URL) -> AVAssetDownloadTask {
        let asset = AVURLAsset(url: url)
        let configuration = AVAssetDownloadConfiguration(asset: asset, title: title)
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = title
        return task
    }

    private func restore(from tasks: [URLSessionTask]) {
        for task in tasks {
            let download = Download(task: task)
            _downloads[download] = .empty
        }
    }

    private func restore() {
        session.getAllTasks { [weak self] tasks in
            self?.restore(from: tasks)
        }
    }
}

extension Downloader: AVAssetDownloadDelegate {
    public func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
        print("--> location: \(location)")
        if let download = _downloads.keys.first(where: { $0.task == assetDownloadTask }) {
            _downloads[download] = .fileUrl(location)
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        print("Error: --> \(error)")
    }
}

#endif
