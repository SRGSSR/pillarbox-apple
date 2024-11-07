//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCircumspect

import Combine
import XCTest

private class Object: ObservableObject {
    @Published var value = 0
}

final class ExpectOutputTests: XCTestCase {
    func testSingleOutput() {
        expectOutput(from: Just([1, 2, 3].publisher))
    }

    func testMultipleOutputs() {
        expectOutput(from: Just([1, 2, 3].publisher))
    }

    func testSingleChange() {
        let object = Object()
        expectChange(from: object) {
            object.value = 1
        }
    }

    func testMultipleChanges() {
        let object = Object()
        expectChange(from: object) {
            object.value = 1
            object.value = 2
            object.value = 3
        }
    }
}
