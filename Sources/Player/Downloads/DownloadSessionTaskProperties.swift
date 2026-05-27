//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DownloadSessionTaskProperties {
    let task: URLSessionTask
    let state: URLSessionTask.State
    let progress: Double

    init(task: URLSessionTask, state: URLSessionTask.State, progress: Double) {
        self.task = task
        self.state = state

        // If progress information is not received (e.g. download happened too fast), still ensure that progress is
        // correct.
        self.progress = (state == .completed) ? 1 : progress
    }
}
