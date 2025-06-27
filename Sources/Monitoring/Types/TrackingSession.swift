//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import os

private final class UncheckedTrackingSession {
    private(set) var id: String?
    private(set) var isStarted = false

    func start() {
        id = UUID().uuidString.lowercased()
        isStarted = true
    }

    func stop() {
        isStarted = false
    }

    func reset() {
        id = nil
        isStarted = false
    }
}

final class TrackingSession {
    private let session = OSAllocatedUnfairLock(initialState: UncheckedTrackingSession())

    var id: String? {
        session.withLock(\.id)
    }

    var isStarted: Bool {
        session.withLock(\.isStarted)
    }

    func start() {
        session.withLock { session in
            session.start()
        }
    }

    func stop() {
        session.withLock { session in
            session.stop()
        }
    }

    func reset() {
        session.withLock { session in
            session.reset()
        }
    }
}
