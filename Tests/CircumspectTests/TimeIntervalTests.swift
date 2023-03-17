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
        expect(DispatchTimeInterval.milliseconds(1_000).double()).to(equal(1))
        expect(DispatchTimeInterval.microseconds(1_000_000).double()).to(equal(1))
        expect(DispatchTimeInterval.nanoseconds(1_000_000_000).double()).to(equal(1))
    }
}
