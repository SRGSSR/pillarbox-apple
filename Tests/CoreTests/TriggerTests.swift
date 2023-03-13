//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Core

import Circumspect
import Combine
import XCTest

final class TriggerTests: XCTestCase {
    func testInactive() {
        let trigger = Trigger()
        expectNothingPublished(from: trigger.signal(activatedBy: 1), during: 1)
    }

    func testActiveWithSignal() {
        let trigger = Trigger()
        expectEqualPublished(values: ["out"], from: trigger.signal(activatedBy: 1).map { _ in "out" }, during: 1) {
            trigger.activate(for: 1)
        }
    }

    func testMultipleActivations() {
        let trigger = Trigger()
        expectEqualPublished(values: ["out", "out"], from: trigger.signal(activatedBy: 1).map { _ in "out" }, during: 1) {
            trigger.activate(for: 1)
            trigger.activate(for: 1)
        }
    }

    func testDifferentActivationIndex() {
        let trigger = Trigger()
        expectNothingPublished(from: trigger.signal(activatedBy: 1), during: 1) {
            trigger.activate(for: 2)
        }
    }

    func testHashableActivationIndex() {
        let trigger = Trigger()
        expectEqualPublished(values: ["out"], from: trigger.signal(activatedBy: "index").map { _ in "out" }, during: 1) {
            trigger.activate(for: "index")
        }
    }
}
