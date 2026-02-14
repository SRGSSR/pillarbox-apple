//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxStandardConnector

import Nimble
import XCTest

final class HTTPURLResponseTests: XCTestCase {
    func testFixedLocalizedStringForValidStatusCode() {
        expect(HTTPURLResponse.fixedLocalizedString(forStatusCode: 404)).to(equal("Not found"))
    }

    func testFixedLocalizedStringForInvalidStatusCode() {
        expect(HTTPURLResponse.fixedLocalizedString(forStatusCode: 956)).to(equal("Server error"))
    }

    func testNetworkLocalizedStringForValidKey() {
        expect(HTTPURLResponse.coreNetworkLocalizedString(forKey: "not found")).to(equal("Not found"))
    }

    func testNetworkLocalizedStringForInvalidKey() {
        expect(HTTPURLResponse.coreNetworkLocalizedString(forKey: "Some key which does not exist")).to(equal("Unknown error."))
    }
}
