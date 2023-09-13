//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Foundation
import Nimble
import XCTest

private final class TestCaseDataSource: AnalyticsDataSource {
    var comScoreGlobals: ComScoreGlobals {
        .init(consent: .unknown, labels: [:])
    }

    var commandersActGlobals: CommandersActGlobals {
        .init(consentServices: ["service1", "service2", "service3"], labels: [:])
    }
}

/// A simple test suite with more tolerant Nimble settings. Beware that `toAlways` and `toNever` expectations appearing
/// in tests will use the same value by default and should likely always provide an explicit `until` parameter.
class TestCase: XCTestCase {
    private static let dataSource = TestCaseDataSource()

    override class func setUp() {
        PollingDefaults.timeout = .seconds(20)
        try? Analytics.shared.start(
            with: .init(vendor: .SRG, sourceKey: "39ae8f94-595c-4ca4-81f7-fb7748bd3f04", appSiteName: "site"),
            dataSource: dataSource
        )
    }

    override class func tearDown() {
        PollingDefaults.timeout = .seconds(1)
    }

    override func setUp() {
        waitUntil { done in
            AnalyticsListener.start(completion: done)
        }
    }
}
