//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import Nimble
import XCTest

final class WeakCapturePublisherTests: XCTestCase {
    func testDeallocation() {
        var object: TestObject? = TestObject()
        let publisher = Just("output")
            .weakCapture(object)

        weak let weakObject = object
        autoreleasepool {
            object = nil
        }
        expect(weakObject).to(beNil())

        expectNothingPublished(from: publisher, during: .seconds(1))
    }

    func testDelivery() {
        let object = TestObject(identifier: "weak_capture")
        let publisher = Just("output")
            .weakCapture(object, at: \.identifier)
        expectAtLeastPublished(
            values: [("output", "weak_capture")],
            from: publisher
        ) { output1, output2 in
            output1.0 == output2.0 && output1.1 == output2.1
        }
    }
}
