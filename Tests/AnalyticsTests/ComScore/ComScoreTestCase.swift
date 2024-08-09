//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Dispatch
import PillarboxCircumspect

class ComScoreTestCase: TestCase {}

extension ComScoreTestCase {
    /// Collects hits emitted by comScore during some time interval and matches them against expectations.
    ///
    /// A network connection is required by the comScore SDK to properly emit hits.
    func expectHits(
        _ expectations: ComScoreHitExpectation...,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureComScoreHits { publisher in
            expectPublished(
                values: expectations,
                from: publisher,
                to: ComScoreHitExpectation.match,
                during: interval,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Expects hits emitted by comScore during some time interval and matches them against expectations.
    ///
    /// A network connection is required by the comScore SDK to properly emit hits.
    func expectAtLeastHits(
        _ expectations: ComScoreHitExpectation...,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureComScoreHits { publisher in
            expectAtLeastPublished(
                values: expectations,
                from: publisher,
                to: ComScoreHitExpectation.match,
                timeout: timeout,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Expects no hits emitted by comScore during some time interval.
    func expectNoHits(
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        AnalyticsListener.captureComScoreHits { publisher in
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
