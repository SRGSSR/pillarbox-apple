//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import OrderedCollections
import UIKit

#if DEBUG
@_spi(DownloaderPrivate)
public final class Downloader: NSObject, ObservableObject {
    static let metadataFileUrl = URL.libraryDirectory.appending(component: "downloads.json")

    private lazy var session = AVAssetDownloadURLSession(
        configuration: .background(withIdentifier: "ch.srgssr.player.downloader"),
        assetDownloadDelegate: self,
        delegateQueue: .main
    )

    private var pendingDownloads: [Download] = []
    private var cancellables = Set<AnyCancellable>()

    @Published private var _downloads: OrderedDictionary<Download, DownloadedFile> = [:] {
        didSet {
            Self.saveDownloads(_downloads)
        }
    }

    public var downloads: [Download] {
        Array(_downloads.keys)
    }

    override public init() {
        super.init()
        restore()
    }

    private static func restoreDownloads(from tasks: [URLSessionTask]) -> OrderedDictionary<Download, DownloadedFile> {
        guard let jsonData = try? Data(contentsOf: metadataFileUrl), let metadata = try? JSONDecoder().decode([DownloadMetadata].self, from: jsonData) else {
            return [:]
        }
        return OrderedDictionary(
            uniqueKeys: metadata.map { metadata in
                let task = tasks.first { $0.taskDescription == metadata.id }
                return Download(metadata: metadata, task: task)
            },
            values: metadata.map(\.file)
        )
    }

    private static func saveDownloads(_ downloads: OrderedDictionary<Download, DownloadedFile>) {
        let metadata = downloads.map { download, file in
            DownloadMetadata(id: download.id, title: download.title, remoteUrl: download.remoteUrl, file: file)
        }
        if let jsonData = try? JSONEncoder().encode(metadata) {
            try? jsonData.write(to: metadataFileUrl)
        }
    }

    func restore() {
        session.getAllTasks { [weak self] tasks in
            self?._downloads = Self.restoreDownloads(from: tasks)
        }
    }

    @discardableResult
    public func add(title: String, url: URL) -> Download {
        let download = Download(
            title: title,
            task: downloadTask(title: title, url: url)
        )
        download.resume()
        pendingDownloads.append(download)
        return download
    }

    public func remove(_ download: Download) {
        download.cancel()
        pendingDownloads.removeAll { $0 == download }
        if let url = fileUrl(for: download, allowsPartial: true) {
            try? FileManager.default.removeItem(at: url)
        }
        _downloads.removeValue(forKey: download)
    }

    public func fileUrl(for download: Download) -> URL? {
        fileUrl(for: download, allowsPartial: false)
    }

    public func isFailed(download: Download) -> Bool {
        switch _downloads[download] {
        case .failed:
            true
        default:
            false
        }
    }

    public func restart(download: Download) {
        switch _downloads[download] {
        case let .failed(remoteUrl, _):
            remove(download)
            add(title: download.title, url: remoteUrl)
        default:
            return
        }

    }

    private func fileUrl(for download: Download, allowsPartial: Bool) -> URL? {
        guard let file = _downloads[download] else { return nil }
        return file.url(allowsPartial: allowsPartial)
    }

    private func downloadTask(title: String, url: URL) -> URLSessionTask {
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: url), title: title)
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = UUID().uuidString
        return task
    }
}

extension Downloader: AVAssetDownloadDelegate {
    public func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
        guard let download = pendingDownloads.first(where: { $0.id == assetDownloadTask.taskDescription }) else { return }
        pendingDownloads.removeAll { $0 == download }
        _downloads[download] = .url(localUrl: location)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let download = _downloads.keys.first(where: { $0.id == task.taskDescription }) else { return }
        if let file = _downloads[download] {
            if error == nil {
                _downloads[download] = file.toBookmark()
            }
            else if let remoteUrl = task.currentRequest?.url, let localUrl = file.url(allowsPartial: true) {
                _downloads[download] = .failed(remoteUrl: remoteUrl, localUrl: localUrl)
            }
            else {
                assertionFailure("💥")
            }
        }
    }
}

#endif
