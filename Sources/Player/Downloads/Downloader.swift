//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import OrderedCollections
import UIKit

struct PendingDownload: Equatable {
    let download: Download
    let replacedDownload: Download?
}

#if DEBUG
@_spi(DownloaderPrivate)
public final class Downloader: NSObject, ObservableObject {
    static let metadataFileUrl = URL.libraryDirectory.appending(component: "downloads.json")

    lazy var session = AVAssetDownloadURLSession(
        configuration: .background(withIdentifier: "ch.srgssr.player.downloader"),
        assetDownloadDelegate: self,
        delegateQueue: .main
    )

    private var pendingDownloads: [PendingDownload] = []
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

    @discardableResult
    public func add(title: String, remoteUrl: URL) -> Download {
        add(title: title, remoteUrl: remoteUrl, replacing: nil)
    }

    public func remove(_ download: Download) {
        do {
            download.cancel()
            pendingDownloads.removeAll { $0.download == download }
            if let url = url(for: download) {
                try FileManager.default.removeItem(at: url)
                _downloads.removeValue(forKey: download)
            }
        }
        catch {}
    }
}

extension Downloader {
    func restore() {
        session.getAllTasks { [weak self] tasks in
            guard let self else { return }
            _downloads = Self.restoreDownloads(from: tasks, downloader: self)
        }
    }

    func restart(download: Download) -> Download {
        add(title: download.title, remoteUrl: download.remoteUrl, replacing: download)
    }

    func link(for download: Download) -> DownloadLink {
        _downloads[download]?.link() ?? .missing
    }

    func url(for download: Download) -> URL? {
        _downloads[download]?.url()
    }
}

private extension Downloader {
    static func restoreDownloads(from tasks: [URLSessionTask], downloader: Downloader) -> OrderedDictionary<Download, DownloadedFile> {
        guard let jsonData = try? Data(contentsOf: metadataFileUrl), let metadata = try? JSONDecoder().decode([DownloadMetadata].self, from: jsonData) else {
            return [:]
        }
        return OrderedDictionary(
            uniqueKeys: metadata.map { metadata in
                let task = tasks.first { $0.taskDescription == metadata.id }
                return Download(metadata: metadata, task: task, downloader: downloader)
            },
            values: metadata.map(\.file)
        )
    }

    static func saveDownloads(_ downloads: OrderedDictionary<Download, DownloadedFile>) {
        let metadata = downloads.map { download, file in
            DownloadMetadata(id: download.id, title: download.title, remoteUrl: download.remoteUrl, file: file)
        }
        if let jsonData = try? JSONEncoder().encode(metadata) {
            try? jsonData.write(to: metadataFileUrl)
        }
    }

    func add(title: String, remoteUrl: URL, replacing replacedDownload: Download?) -> Download {
        let download = Download(title: title, remoteUrl: remoteUrl, downloader: self)
        download.resume()
        pendingDownloads.append(.init(download: download, replacedDownload: replacedDownload))
        return download
    }
}

extension Downloader: AVAssetDownloadDelegate {
    public func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
        guard let pendingDownload = pendingDownloads.first(where: { $0.download.id == assetDownloadTask.taskDescription }) else {
            return
        }
        pendingDownloads.removeAll { $0 == pendingDownload }
        if let replacedDownload = pendingDownload.replacedDownload {
            if let index = _downloads.index(forKey: replacedDownload) {
                _downloads.updateValue(.partial(location), forKey: pendingDownload.download, insertingAt: index)
            }
            else {
                _downloads[pendingDownload.download] = .partial(location)
            }
            remove(replacedDownload)
        }
        else {
            _downloads[pendingDownload.download] = .partial(location)
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let download = _downloads.keys.first(where: { $0.id == task.taskDescription }), let file = _downloads[download] else { return }
        _downloads[download] = file.complete(with: error)
    }
}

#endif
