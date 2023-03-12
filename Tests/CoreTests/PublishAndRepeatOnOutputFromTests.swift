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
        expectEqualPublished(values: ["out"], from: publisher, during: 1)
    }

    func testInactiveSignal() {
        let publisher = Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: 1)) {
            Just("out")
        }
        expectEqualPublished(values: ["out"], from: publisher, during: 1)
    }

    func testActiveSignal() {
        let publisher = Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: 1)) {
            Just("out")
        }
        expectEqualPublished(values: ["out", "out"], from: publisher, during: 1) { [trigger] in
            trigger.activate(for: 1)
        }
    }
}
