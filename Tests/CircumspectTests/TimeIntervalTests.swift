//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Circumspect

import Dispatch
import Nimble
import XCTest

final class TimeIntervalTests: XCTestCase {
    func testDoubleConversion() {
        expect(DispatchTimeInterval.seconds(1).double()).to(equal(1))
        expect(DispatchTimeInterval.milliseconds(1000).double()).to(equal(1))
        expect(DispatchTimeInterval.microseconds(1000000).double()).to(equal(1))
        expect(DispatchTimeInterval.nanoseconds(1000000000).double()).to(equal(1))
    }
}
