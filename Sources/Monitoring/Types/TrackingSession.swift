//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct TrackingSession {
    private(set) var id: String?
    private(set) var isStarted = false

    mutating func start() {
        id = UUID().uuidString.lowercased()
        isStarted = true
    }

    mutating func stop() {
        isStarted = false
    }

    mutating func reset() {
        id = nil
        isStarted = false
    }
}
