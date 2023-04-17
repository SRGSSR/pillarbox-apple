//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Circumspect

import Combine
import XCTest

final class ExpectResultTests: XCTestCase {
    func testExpectSuccess() {
        expectSuccess(from: Empty<Int, Error>())
    }

    func testExpectFailure() {
        expectFailure(from: Fail<Int, Error>(error: StructError()))
    }

    func testExpectFailureWithError() {
        expectFailure(StructError(), from: Fail<Int, Error>(error: StructError()))
    }
}
