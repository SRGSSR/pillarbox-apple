//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Nimble
import PillarboxStandardConnector
import XCTest

final class StandardConnectorTests: XCTestCase {
    func testDummy() {
        expect(StandardConnector.run()).to(equal("connected"))
    }
}
