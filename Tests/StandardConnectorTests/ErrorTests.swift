//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

@_spi(StandardConnectorPrivate)
import PillarboxStandardConnector

import Nimble
import XCTest

final class ErrorTests: XCTestCase {
    func testHttpError() {
        expect(HttpError(statusCode: 404)).notTo(beNil())
    }

    func testNotHttpError() {
        expect(HttpError(statusCode: 200)).to(beNil())
    }
}
