//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Core

import Circumspect
import Combine
import XCTest

final class PublishAndRepeatOnOutputFromTests: XCTestCase {
    private let trigger = Trigger()

    func testNoSignal() {
        let publisher = Publishers.PublishAndRepeat(onOutputFrom: Optional<AnyPublisher<Void, Never>>.none) {
            Just("out")
        }
        expectAtLeastEqualPublished(values: ["out"], from: publisher)
    }

    func testInactiveSignal() {
        let publisher = Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: 1)) {
            Just("out")
        }
        expectAtLeastEqualPublished(values: ["out"], from: publisher)
    }

    func testActiveSignal() {
        let publisher = Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: 1)) {
            Just("out")
        }
        expectAtLeastEqualPublished(values: ["out", "out"], from: publisher) { [trigger] in
            trigger.activate(for: 1)
        }
    }
}
