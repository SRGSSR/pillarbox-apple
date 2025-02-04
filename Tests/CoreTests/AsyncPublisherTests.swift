//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import PillarboxCircumspect
import XCTest

private struct MockError: Error {}

final class AsyncPublisherTests: XCTestCase {
    func testNonThrowingSuccess() {
        let publisher = AsyncPublisher {
            "success"
        }
        expectOnlyEqualPublished(values: ["success"], from: publisher)
    }

    func testThrowingSuccess() {
        let publisher = AsyncPublisher {
            try await Task.sleep(for: .milliseconds(500))
        }
        expectSuccess(from: publisher)
    }

    func testThrowingFailure() {
        let publisher = AsyncPublisher {
            throw MockError()
        }
        expectFailure(from: publisher)
    }
}
