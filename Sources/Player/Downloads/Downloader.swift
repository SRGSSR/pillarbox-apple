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
        let existingMetadata = metadata.filter { metadata in
            guard let fileUrl = metadata.file.url(allowsPartial: true) else { return false }
            return FileManager.default.fileExists(atPath: fileUrl.path)
        }
        return OrderedDictionary(
            uniqueKeys: existingMetadata.map { metadata in
                let task = tasks.first { $0.taskDescription == metadata.id }
                return Download(id: metadata.id, title: metadata.title, task: task)
            },
            values: existingMetadata.map(\.file)
        )
    }

    private static func saveDownloads(_ downloads: OrderedDictionary<Download, DownloadedFile>) {
        let metadata = downloads.map { download, file in
            DownloadMetadata(id: download.id, title: download.title, file: file)
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

    public func errorMessage(for download: Download) -> String? {
        guard let file = _downloads[download] else { return nil }
        return file.errorMessage()
    }

    private func fileUrl(for download: Download, allowsPartial: Bool) -> URL? {
        guard let file = _downloads[download] else { return nil }
        return file.url(allowsPartial: allowsPartial)
    }

    private func downloadTask(title: String, url: URL) -> URLSessionTask {
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: url), title: title)
        return session.makeAssetDownloadTask(downloadConfiguration: configuration)
    }
}

extension Downloader: AVAssetDownloadDelegate {
    public func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
        guard let download = pendingDownloads.first(where: { $0.id == assetDownloadTask.taskDescription }) else { return }
        pendingDownloads.removeAll { $0 == download }
        _downloads[download] = .url(location)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let download = _downloads.keys.first(where: { $0.id == task.taskDescription }) else { return }
        if let error {
            _downloads[download] = .failed(error.localizedDescription)
        }
        else if let file = _downloads[download] {
            _downloads[download] = file.toBookmark()
        }
    }
}

#endif
