//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DownloadSource {
    case estimate(Double)
    case task(DownloadSessionTask)

    private var task: URLSessionTask? {
        switch self {
        case .estimate:
            return nil
        case let .task(properties):
            return properties.task
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
