//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Nimble
import XCTest

final class ChaptersTests: XCTestCase {
    private static func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }

    func testNotBlocked() {
        expect(Mock.chapter().blockingReason()).to(beNil())
    }

    func testGeoblocked() {
        expect(Mock.chapter(.geoblocked).blockingReason()).to(equal(.geoblocked))
    }

    func testAvailable() {
        let date = Self.date(year: 2022, month: 09, day: 21)
        expect(Mock.chapter(.timeLimited).blockingReason(at: date)).to(beNil())
    }

    func testNotAvailableYet() {
        let date = Self.date(year: 2022, month: 01, day: 01)
        expect(Mock.chapter(.timeLimited).blockingReason(at: date)).to(equal(.startDate))
    }

    func testNotAvailableAnymore() {
        let date = Self.date(year: 2022, month: 12, day: 31)
        expect(Mock.chapter(.timeLimited).blockingReason(at: date)).to(equal(.endDate))
    }

    func testSegments() {
        expect(Mock.chapter(.segments).segments).toNot(beEmpty())
    }
}
