//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import PillarboxCircumspect
import XCTest

final class TriggerTests: XCTestCase {
    func testInactive() {
        let trigger = Trigger()
        expectNothingPublished(from: trigger.signal(activatedBy: 1), during: .seconds(1))
    }

    func testActiveWithSignal() {
        let trigger = Trigger()
        expectAtLeastEqualPublished(values: ["out"], from: trigger.signal(activatedBy: 1).map { _ in "out" }) {
            trigger.activate(for: 1)
        }
    }

    func testMultipleActivations() {
        let trigger = Trigger()
        expectAtLeastEqualPublished(values: ["out", "out"], from: trigger.signal(activatedBy: 1).map { _ in "out" }) {
            trigger.activate(for: 1)
            trigger.activate(for: 1)
        }
    }

    func testDifferentActivationIndex() {
        let trigger = Trigger()
        expectNothingPublished(from: trigger.signal(activatedBy: 1), during: .seconds(1)) {
            trigger.activate(for: 2)
        }
    }

    func testHashableActivationIndex() {
        let trigger = Trigger()
        expectAtLeastEqualPublished(values: ["out"], from: trigger.signal(activatedBy: "index").map { _ in "out" }) {
            trigger.activate(for: "index")
        }
    }
}
