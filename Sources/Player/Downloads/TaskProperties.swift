//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct TaskProperties {
    let task: URLSessionTask
    let state: URLSessionTask.State
    let progress: Double

    init(task: URLSessionTask, state: URLSessionTask.State, progress: Double) {
        self.task = task
        self.state = state
        self.progress = progress
    }
}
