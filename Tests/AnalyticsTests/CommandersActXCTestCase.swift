//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import XCTest

extension XCTestCase {
    /// Collect events emitted by Commanders Act during some time interval and match them against expectations.
    func expectCommandersActEvents(
        _ expectations: [CommandersActEventExpectation],
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: (() -> Void)? = nil
    ) {
        CommandersActRecorder.captureEvents { publisher in
            expectPublished(
                values: expectations,
                from: publisher,
                to: CommandersActEventExpectation.match(event:with:),
                during: interval,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Expect events emitted by Commanders Act during some time interval and match them against expectations.
    func expectAtLeastCommandersActEvents(
        _ expectations: [CommandersActEventExpectation],
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: (() -> Void)? = nil
    ) {
        CommandersActRecorder.captureEvents { publisher in
            expectAtLeastPublished(
                values: expectations,
                from: publisher,
                to: CommandersActEventExpectation.match(event:with:),
                timeout: timeout,
                file: file,
                line: line,
                while: executing
            )
        }
    }
}
