//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Combine
import Nimble
import XCTest

final class WeakCapturePublisherTests: XCTestCase {
    func testDeallocation() {
        var object: TestObject? = TestObject()
        let publisher = Just("hello, world!")
            .weakCapture(object)

        weak var weakObject = object
        autoreleasepool {
            object = nil
        }
        expect(weakObject).to(beNil())

        expectNothingPublished(from: publisher, during: 1)
    }
}
