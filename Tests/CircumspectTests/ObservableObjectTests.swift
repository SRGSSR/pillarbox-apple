//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Circumspect

import Nimble
import XCTest

private class TestObservableObject: ObservableObject {
    @Published var publishedProperty1: Int = 1
    @Published var publishedProperty2: String = "a"

    var nonPublishedProperty: Int {
        return publishedProperty1 * 2
    }
}

final class ObservableObjectTests: XCTestCase {
    func testNonPublishedPropertyInitialValue() {
        let object = TestObservableObject()
        expectAtLeastEqualPublished(
            values: [2],
            from: object.changePublisher(at: \.nonPublishedProperty),
            timeout: 2
        )
    }

    func testPublishedPropertyInitialValue() {
        let object = TestObservableObject()
        expectAtLeastEqualPublished(
            values: [1],
            from: object.changePublisher(at: \.publishedProperty1),
            timeout: 2
        )
    }

    func testNonPublishedPropertyChanges() {
        let object = TestObservableObject()
        expectAtLeastEqualPublished(
            values: [2, 8, 8],
            from: object.changePublisher(at: \.nonPublishedProperty),
            timeout: 2
        ) {
            object.publishedProperty1 = 4
            object.publishedProperty2 = "b"
        }
    }

    func testPublishedPropertyChanges() {
        let object = TestObservableObject()
        expectAtLeastEqualPublished(
            values: [1, 3, 3, 3],
            from: object.changePublisher(at: \.publishedProperty1),
            timeout: 2
        ) {
            object.publishedProperty1 = 2
            object.publishedProperty1 = 3
            object.publishedProperty2 = "b"
        }
    }

    func testDeallocation() {
        var object: TestObservableObject? = TestObservableObject()
        _ = object?.changePublisher(at: \.nonPublishedProperty)
        weak var weakObject = object
        autoreleasepool {
            object = nil
        }
        expect(weakObject).to(beNil())
    }
}
