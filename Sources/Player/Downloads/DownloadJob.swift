//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DownloadJob {
    case none(estimatedProgress: Double)
    case task(properties: DownloadTaskProperties)

    private var task: URLSessionTask? {
        switch self {
        case .none:
            return nil
        case let .task(properties: properties):
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
