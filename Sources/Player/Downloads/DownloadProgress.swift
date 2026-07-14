//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@available(tvOS, unavailable)
enum DownloadProgress {
    case estimate(Double, location: URL?, error: Error?)
    case actual(DownloadSessionTaskProperties)

    var location: URL? {
        switch self {
        case let .estimate(_, location, _):
            return location
        case let .actual(properties):
            return properties.location
        }
    }

    var error: Error? {
        switch self {
        case let .estimate(_, _, error):
            return error
        case let .actual(properties):
            return properties.error
        }
    }

    var fractionCompleted: Double {
        if error != nil {
            return 0
        }
        switch self {
        case let .estimate(progress, _, _):
            return progress
        case let .actual(properties):
            return properties.progress
        }
    }

    var task: URLSessionTask? {
        switch self {
        case .estimate:
            return nil
        case let .actual(properties):
            return properties.task
        }
    }
}

#endif
