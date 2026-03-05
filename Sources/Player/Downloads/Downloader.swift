//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import OrderedCollections

private enum Location {
    case empty
    case url(URL)
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

    override public init() {}

    @discardableResult
    public func add(title: String, url: URL) -> Download {
        let download = Download(title: title, url: url, session: session)
        _downloads[download] = .empty
        return download
    }

    public func remove(_ download: Download) {
        _downloads.removeValue(forKey: download)
    }

    public func fileUrl(for download: Download) -> URL? {
        if let location = _downloads[download], case let .url(url) = location {
            return url
        }
        else {
            return nil
        }
    }
}

extension Downloader: AVAssetDownloadDelegate {
    public func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
        if let download = _downloads.keys.first(where: { $0.task == assetDownloadTask }) {
            _downloads[download] = .url(location)
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        print("Error: --> \(error)")
    }
}

#endif
