//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Nimble
import XCTest

final class ErrorTests: XCTestCase {
    func testHttpError() {
        let error = NSError.httpError(withStatusCode: 404)!
        expect(error.domain).to(equal("ch.srgssr.pillarbox.core_business.network"))
        expect(error.code).to(equal(404))
        expect(error.localizedDescription).notTo(beNil())
    }

    func testNotHttpError() {
        expect(NSError.httpError(withStatusCode: 200)).to(beNil())
    }
}

