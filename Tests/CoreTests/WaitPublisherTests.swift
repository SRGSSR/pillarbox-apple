//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import PillarboxCircumspect
import XCTest

final class WaitPublisherTests: XCTestCase {
    func testWait() {
        let signal = PassthroughSubject<Void, Never>()

        let publisher = Just("Received")
            .wait(untilOutputFrom: signal)
        expectNothingPublished(from: publisher, during: .milliseconds(100))

        expectAtLeastEqualPublished(values: ["Received"], from: publisher) {
            signal.send(())
        }
    }
}
