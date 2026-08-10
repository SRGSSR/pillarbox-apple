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
    let size: DownloadSize?
    let speed: Int?

    var fractionCompleted: Double {
        if let size {
            return size.fractionCompleted
        }
        else {
            // If progress information is indeterminate (e.g. download happened too fast), still ensure that fraction completed is
            // correct.
            return state == .completed ? 1 : 0
        }
    }
}

#endif
