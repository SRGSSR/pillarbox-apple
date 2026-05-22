//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DownloadSessionProvider {
    case urlSession(URLSessionConfiguration)
    case custom(DownloadSession)
}
