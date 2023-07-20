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
    /// Collects hits emitted by Commanders Act during some time interval and matches them against expectations.
    func expectHits(
        _ expectations: CommandersActHitExpectation...,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureCommandersActHits { publisher in
            expectPublished(
                values: expectations,
                from: publisher,
                to: CommandersActHitExpectation.match,
                during: interval,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Expects hits emitted by Commanders Act during some time interval and matches them against expectations.
    func expectAtLeastHits(
        _ expectations: CommandersActHitExpectation...,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureCommandersActHits { publisher in
            expectAtLeastPublished(
                values: expectations,
                from: publisher,
                to: CommandersActHitExpectation.match,
                timeout: timeout,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Expects no hits emitted by Commanders Act during some time interval.
    func expectNoHits(
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureCommandersActHits { publisher in
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
