//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import Combine
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
        Self.setupAnalytics()
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
        Self.setupAnalytics()
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

    /// Wait until a `didReceiveComScoreRequest` notification has been received as a result of executing some code.
    func wait(
        timeout: DispatchTimeInterval = .seconds(20),
        function: String = #function,
        while executing: () -> Void,
        received: @escaping ([String: String]) -> Void
    ) {
        Self.setupAnalytics()
        ComScoreRecorder.captureEvents { publisher in
//            expectation(forNotification: .didReceiveComScoreRequest, object: nil) { notification in
//                guard let labels = notification.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String],
//                      labels[Analytics.testIdentifierKey] == id else {
//                    return false
//                }
//                received(labels)
//                return true
//            }
//            executing()
//            waitForExpectations(timeout: timeout.double())
        }
    }

    static func setupAnalytics() {
        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))
    }
}
