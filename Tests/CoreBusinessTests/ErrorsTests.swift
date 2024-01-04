//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCoreBusiness

import Nimble
import XCTest

final class ErrorTests: XCTestCase {
    func testHttpError() {
        expect(DataError.http(withStatusCode: 404)).notTo(beNil())
    }

    func testNotHttpNSError() {
        expect(DataError.http(withStatusCode: 200)).to(beNil())
    }
}
