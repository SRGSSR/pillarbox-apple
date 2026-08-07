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
    let completedUnitCount: Int64
    let totalUnitCount: Int64?
    let fractionCompleted: Double
}

#endif
