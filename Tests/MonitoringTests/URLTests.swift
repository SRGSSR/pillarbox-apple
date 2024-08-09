//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxMonitoring

import Nimble
import XCTest

final class URLTests: XCTestCase {
    func testNonNil() {
        expect(URL(string: "https://localhost")).notTo(beNil())
    }

    func testNil() {
        expect(URL(string: nil)).to(beNil())
    }
}
