//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DownloadPlayerProperties {
    static let empty = Self(metadata: .empty, taskProperties: nil, location: nil, error: nil)

    let metadata: PlayerMetadata
    let taskProperties: TaskProperties?
    let location: URL?
    let error: Error?

    var state: DownloadState {
        if let error {
            return .failed(error)
        }
        else if let taskProperties {
            switch taskProperties.state {
            case .running, .canceling:
                return .running
            case .suspended:
                return .suspended
            case .completed:
                return .completed
            @unknown default:
                assertionFailure("Unhandled case")
                return .completed
            }
        }
        else if location != nil {
            return .completed
        }
        else {
            return .preparing
        }
    }

    func location(allowsPartial: Bool) -> URL? {
        switch state {
        case .completed:
            return location
        default:
            return allowsPartial ? location : nil
        }
    }
}
