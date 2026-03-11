//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DownloadedFile: Codable {
    case partial(URL)
    case bookmark(Data)
    case missing(URL)

    func complete(with error: Error?) -> Self {
        switch self {
        case let .partial(url) where error == nil:
            guard let data = try? url.bookmarkData() else { return .missing(url) }
            return .bookmark(data)
        case let .partial(url):
            return .missing(url)
        default:
            return self
        }
    }

    func link() -> DownloadLink {
        switch self {
        case let .bookmark(data):
            guard let url = Self.url(from: data) else { return .missing }
            return .available(url)
        default:
            return .missing
        }
    }

    func url() -> URL? {
        switch self {
        case let .partial(url), let .missing(url):
            return url
        case let .bookmark(data):
            return Self.url(from: data)
        }
    }

    private static func url(from bookmark: Data) -> URL? {
        var bookmarkDataIsStale = false
        return try? URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &bookmarkDataIsStale)
    }
}
