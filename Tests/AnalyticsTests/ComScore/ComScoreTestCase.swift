//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import XCTest

class ComScoreTestCase: XCTestCase {}

extension ComScoreTestCase {
    /// Collect events emitted by comScore during some time interval and match them against expectations.
    func expectEvents(
        _ expectations: [ComScoreEventExpectation],
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureComScoreEvents { publisher in
            expectPublished(
                values: expectations,
                from: publisher,
                to: ComScoreEventExpectation.match,
                during: interval,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Expect events emitted by comScore during some time interval and match them against expectations.
    func expectAtLeastEvents(
        _ expectations: [ComScoreEventExpectation],
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureComScoreEvents { publisher in
            expectAtLeastPublished(
                values: expectations,
                from: publisher,
                to: ComScoreEventExpectation.match,
                timeout: timeout,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Expect no events emitted by comScore during some time interval.
    func expectNoEvents(
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureComScoreEvents { publisher in
            expectNothingPublished(
                from: publisher,
                during: interval,
                file: file,
                line: line,
                while: executing
            )
        }
    }
}
