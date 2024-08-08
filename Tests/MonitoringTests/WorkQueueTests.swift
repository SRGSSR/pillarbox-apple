//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxMonitoring

import Nimble
import XCTest

private struct MockError: Error {}

final class WorkQueueTests: XCTestCase {
    func testProcessItems() {
        let queue = WorkQueue()
        waitUntil { done in
            queue.add {
                try await Task.sleep(milliseconds: 100)
            }
            queue.add {
                try await Task.sleep(milliseconds: 100)
                done()
            }
            queue.process()
        }
        expect(queue.count).to(equal(0))
    }

    func testProcessItemsWithFailure() {
        let queue = WorkQueue()
        queue.add {
            throw MockError()
        }
        queue.add {
            try await Task.sleep(milliseconds: 100)
        }
        queue.process()
        expect(queue.count).toAlways(equal(2), until: .milliseconds(500))
    }
}

private extension Task where Success == Never, Failure == Never {
    static func sleep(milliseconds: UInt64) async throws {
        try await sleep(nanoseconds: milliseconds * 1_000_000)
    }
}
