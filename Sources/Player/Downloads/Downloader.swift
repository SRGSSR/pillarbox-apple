//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class Downloader {
    private(set) var downloads: Set<Download> = []

    @discardableResult
    func add(url: URL) -> Download {
        let download = Download(url: url)
        downloads.insert(download)
        return download
    }

    func remove(_ download: Download) {
        downloads.remove(download)
    }
}
