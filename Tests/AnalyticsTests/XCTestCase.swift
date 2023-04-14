//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import XCTest

extension XCTestCase {
    /// Collect events emitted by comScore under the specified key during some time interval and match them against
    /// an expected result.
    func expectComScoreEvents(
        _ expectations: [ComScoreEventExpectation],
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: (() -> Void)? = nil
    ) {
        ComScoreRecorder.captureEvents { publisher in
            expectPublished(
                values: expectations,
                from: publisher,
                to: ComScoreEventExpectation.match(event:with:),
                during: interval,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Collect events emitted by comScore under the specified key during some time interval and match them against
    /// an expected result.
    func expectAtLeastComScoreEvents(
        _ expectations: [ComScoreEventExpectation],
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: (() -> Void)? = nil
    ) {
        ComScoreRecorder.captureEvents { publisher in
            expectAtLeastPublished(
                values: expectations,
                from: publisher,
                to: ComScoreEventExpectation.match(event:with:),
                timeout: timeout,
                file: file,
                line: line,
                while: executing
            )
        }
    }
}
