//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DownloadLocation {
    case unknown
    case unreliable(URL)
    case bookmark(Data)

    func bookmarkData() -> Data? {
        switch self {
        case let .bookmark(data):
            return data
        default:
            return nil
        }
    }

    func toBookmark() -> Self? {
        switch self {
        case .bookmark:
            return self
        case let .unreliable(url):
            if let data = try? url.bookmarkData() {
                return .bookmark(data)
            }
            else {
                return nil
            }
        default:
            return nil
        }
    }

    init(from data: Data?) {
        if let data {
            self = .bookmark(data)
        }
        else {
            self = .unknown
        }
    }
}
