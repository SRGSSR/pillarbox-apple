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

    private var pendingDownloads: [Download] = []

    @Published private var _downloads: OrderedDictionary<Download, URL> = [:] {
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

    private static func restoreDownloads(from tasks: [URLSessionTask]) -> OrderedDictionary<Download, URL> {
        guard let jsonData = try? Data(contentsOf: metadataFileUrl), let metadata = try? JSONDecoder().decode([DownloadMetadata].self, from: jsonData) else {
            return [:]
        }
        return OrderedDictionary(
            uniqueKeys: metadata.map { metadata in
                let task = tasks.first { $0.taskDescription == metadata.id }
                return Download(id: metadata.id, title: metadata.title, task: task)
            },
            values: metadata.map(\.fileUrl)
        )
    }

    private static func saveDownloads(_ downloads: OrderedDictionary<Download, URL>) {
        let metadata = downloads.map { download, url in
            DownloadMetadata(id: download.id, title: download.title, fileUrl: url)
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
        _downloads.removeValue(forKey: download)
    }

    public func fileUrl(for download: Download) -> URL? {
        _downloads[download]
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
        _downloads[download] = location
    }
}

#endif
