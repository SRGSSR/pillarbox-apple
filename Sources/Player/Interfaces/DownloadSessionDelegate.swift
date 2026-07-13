//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@available(tvOS, unavailable)
protocol DownloadSessionDelegate: AnyObject {
    func downloadSessionWillDownloadToLocation(_ location: URL, task: URLSessionTask, forId id: String)
    func downloadSessionDidCompleteWithError(_ error: (any Error)?, task: URLSessionTask, forId id: String)
}
