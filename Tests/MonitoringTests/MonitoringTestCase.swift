//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxMonitoring

import Dispatch
import PillarboxCircumspect
import XCTest

class MonitoringTestCase: XCTestCase {}

extension MonitoringTestCase {
    /// Collects metric hits during some time interval and matches them against expectations.
    func expectHits(
        _ expectations: any MetricHitExpectation...,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        MetricHitListener.captureMetricHits { publisher in
            expectPublished(
                values: expectations,
                from: publisher,
                to: match(payload:with:),
                during: interval,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Expects metric hits during some time interval and matches them against expectations.
    func expectAtLeastHits(
        _ expectations: any MetricHitExpectation...,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        MetricHitListener.captureMetricHits { publisher in
            expectAtLeastPublished(
                values: expectations,
                from: publisher,
                to: match(payload:with:),
                timeout: timeout,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Expect no metric hits during some time interval.
    func expectNoHits(
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        MetricHitListener.captureMetricHits { publisher in
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
