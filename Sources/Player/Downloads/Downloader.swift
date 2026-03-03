//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class Downloader {
    private(set) var downloads: [Download] = []

    func add(url: URL) {
        downloads.append(Download())
    }
}
