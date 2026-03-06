//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DownloadedFile: Codable {
    case url(URL)
    case bookmark(Data)

    func url(allowsPartial: Bool) -> URL? {
        switch self {
        case let .url(url):
            return allowsPartial ? url : nil
        case let .bookmark(data):
            var bookmarkDataIsStale = false
            return try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &bookmarkDataIsStale)
        }
    }

    func toBookmark() -> Self? {
        switch self {
        case let .url(url):
            guard let data = try? url.bookmarkData() else { return nil }
            return .bookmark(data)
        case .bookmark:
            return self
        }
    }
}
