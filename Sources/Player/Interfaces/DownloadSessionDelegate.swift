//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@available(tvOS, unavailable)
protocol DownloadSessionDelegate: AnyObject {
    func downloadSessionTask(_ task: URLSessionTask, willDownloadToLocation location: URL, forId id: String)
    func downloadSessionTask(_ task: URLSessionTask, didCompleteWithError error: (any Error)?, forId id: String)
}
