//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import PillarboxCircumspect
import XCTest

final class PublishOnOutputFromTests: XCTestCase {
    private let trigger = Trigger()

    func testNoSignal() {
        let publisher = Publishers.Publish(onOutputFrom: Optional<AnyPublisher<Void, Never>>.none) {
            Just("out")
        }
        expectNothingPublished(from: publisher, during: .seconds(1))
    }

    func testInactiveSignal() {
        let publisher = Publishers.Publish(onOutputFrom: trigger.signal(activatedBy: 1)) {
            Just("out")
        }
        expectNothingPublished(from: publisher, during: .seconds(1))
    }

    func testActiveSignal() {
        let publisher = Publishers.Publish(onOutputFrom: trigger.signal(activatedBy: 1)) {
            Just("out")
        }
        expectAtLeastEqualPublished(values: ["out"], from: publisher) { [trigger] in
            trigger.activate(for: 1)
        }
    }
}
