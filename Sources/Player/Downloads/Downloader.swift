//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class Downloader {
    private(set) var downloads: Set<Download> = []
    private lazy var session = AVAssetDownloadURLSession(
        configuration: .background(withIdentifier: "ch.srgssr.player.downloader"),
        assetDownloadDelegate: nil,
        delegateQueue: nil
    )

    @discardableResult
    func add(url: URL) -> Download {
        let download = Download(url: url, session: session)
        downloads.insert(download)
        return download
    }

    func remove(_ download: Download) {
        downloads.remove(download)
    }
}
