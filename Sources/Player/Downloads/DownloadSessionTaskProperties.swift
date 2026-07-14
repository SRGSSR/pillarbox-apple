//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@available(tvOS, unavailable)
struct DownloadSessionTaskProperties {
    let task: URLSessionTask
    let state: URLSessionTask.State
    let progress: Double
    let location: URL?
    let error: Error?
}

#endif
