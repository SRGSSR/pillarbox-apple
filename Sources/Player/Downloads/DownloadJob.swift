//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DownloadJob {
    case none(estimatedProgress: Double)
    case task(DownloadTask)

    private var task: URLSessionTask? {
        switch self {
        case .none:
            return nil
        case let .task(task):
            return task.task
        }
    }

    func resume() {
        task?.resume()
    }

    func suspend() {
        task?.suspend()
    }

    func cancel() {
        task?.cancel()
    }
}
