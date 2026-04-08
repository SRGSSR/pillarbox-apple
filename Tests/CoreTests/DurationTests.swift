//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import CoreMedia
import Nimble
import XCTest

final class DurationTests: XCTestCase {
    func testTimeInterval() {
        let duration = Duration(secondsComponent: 2, attosecondsComponent: Int64(6e17))
        expect(duration.timeInterval()).to(equal(2.6))
    }
}
