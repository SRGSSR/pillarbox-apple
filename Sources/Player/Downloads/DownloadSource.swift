//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@available(tvOS, unavailable)
enum DownloadSourceKind {
    case estimate(Double)
    case task(DownloadSessionTaskProperties)
}

@available(tvOS, unavailable)
struct DownloadSource<CustomData> {
    let kind: DownloadSourceKind
    let metadata: AssetMetadata<CustomData>?

    private var task: URLSessionTask? {
        switch kind {
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
