//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import OrderedCollections

#if DEBUG
@_spi(DownloaderPrivate)
public final class Downloader: NSObject, ObservableObject {
    static let metadataFileUrl = URL.libraryDirectory.appending(component: "downloads.json")

    private lazy var session = AVAssetDownloadURLSession(
        configuration: .background(withIdentifier: "ch.srgssr.player.downloader"),
        assetDownloadDelegate: self,
        delegateQueue: .main
    )

    @Published private var _downloads: OrderedDictionary<Download, DownloadedFile> {
        didSet {
            Self.saveDownloads(_downloads)
        }
    }

    public var downloads: [Download] {
        Array(_downloads.keys)
    }

    override public init() {
        _downloads = Self.restoreDownloads()
    }

    private static func restoreDownloads() -> OrderedDictionary<Download, DownloadedFile> {
        guard let jsonData = try? Data(contentsOf: metadataFileUrl), let metadata = try? JSONDecoder().decode([DownloadMetadata].self, from: jsonData) else {
            return [:]
        }
        return OrderedDictionary(
            uniqueKeys: metadata.map { Download(title: $0.title, taskDescription: $0.taskDescription) },
            values: metadata.map { .available($0.fileUrl) }
        )
    }

    private static func saveDownloads(_ downloads: OrderedDictionary<Download, DownloadedFile>) {
        let metadata = downloads.compactMap { download, file -> DownloadMetadata? in
            guard let fileUrl = file.url() else { return nil }
            return DownloadMetadata(title: download.title, fileUrl: fileUrl, taskDescription: download.taskDescription)
        }
        if let jsonData = try? JSONEncoder().encode(metadata) {
            try? jsonData.write(to: metadataFileUrl)
        }
    }

    @discardableResult
    public func add(title: String, url: URL) -> Download {
        let taskDescription = UUID().uuidString
        let task = downloadTask(title: title, taskDescription: taskDescription, url: url)
        let download = Download(title: title, taskDescription: taskDescription, task: task)
        download.resume()
        _downloads[download] = .missing
        return download
    }

    public func remove(_ download: Download) {
        _downloads.removeValue(forKey: download)
    }

    public func fileUrl(for download: Download) -> URL? {
        guard let file = _downloads[download], case let .available(url) = file else { return nil }
        return url
    }

    private func downloadTask(title: String, taskDescription: String, url: URL) -> URLSessionTask {
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: url), title: title)
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = taskDescription
        return task
    }
}

extension Downloader: AVAssetDownloadDelegate {
    public func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
        guard let download = _downloads.keys.first(where: { $0.taskDescription == assetDownloadTask.taskDescription }) else { return }
        _downloads[download] = .available(location)
    }
}

#endif
