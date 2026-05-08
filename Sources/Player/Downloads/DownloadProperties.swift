//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DownloadProperties<Metadata> {
    let metadata: Metadata?
    let error: Error?
    let task: URLSessionTask?
    let state: URLSessionTask.State
    let progress: Double
    let bookmarkData: Data?

    init(metadata: Metadata? = nil, error: Error? = nil, task: URLSessionTask? = nil, state: URLSessionTask.State = .running, progress: Double = 0, bookmarkData: Data? = nil) {
        self.metadata = metadata
        self.error = error
        self.task = task
        self.state = state
        self.progress = progress
        self.bookmarkData = bookmarkData
    }
}
