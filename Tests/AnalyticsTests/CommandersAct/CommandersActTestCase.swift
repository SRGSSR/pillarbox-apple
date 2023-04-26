//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import XCTest

class CommandersActTestCase: TestCase {}

extension CommandersActTestCase {
    /// Collect events emitted by Commanders Act during some time interval and match them against expectations.
    func expectEvents(
        _ expectations: CommandersActEventExpectation...,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureCommandersActEvents { publisher in
            expectPublished(
                values: expectations,
                from: publisher,
                to: CommandersActEventExpectation.match,
                during: interval,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Expect events emitted by Commanders Act during some time interval and match them against expectations.
    func expectAtLeastEvents(
        _ expectations: CommandersActEventExpectation...,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureCommandersActEvents { publisher in
            expectAtLeastPublished(
                values: expectations,
                from: publisher,
                to: CommandersActEventExpectation.match,
                timeout: timeout,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Expect no events emitted by Commanders Act during some time interval.
    func expectNoEvents(
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureCommandersActEvents { publisher in
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
