//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DownloadedFile {
    case missing
    case available(URL)

    func url() -> URL? {
        switch self {
        case .missing:
            return nil
        case let .available(url):
            return url
        }
    }
}
