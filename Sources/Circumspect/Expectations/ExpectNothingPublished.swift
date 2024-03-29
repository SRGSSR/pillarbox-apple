//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

public extension XCTestCase {
    /// Expects a publisher to not emit any value during some time interval.
    func expectNothingPublished<P>(
        from publisher: P,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P: Publisher, P.Failure == Never {
        expectNothingPublished(
            next: false,
            from: publisher,
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expects a publisher to not emit any value during some time interval.
    func expectNothingPublishedNext<P>(
        from publisher: P,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P: Publisher, P.Failure == Never {
        expectNothingPublished(
            next: true,
            from: publisher,
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }

    private func expectNothingPublished<P>(
        next: Bool,
        from publisher: P,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P: Publisher, P.Failure == Never {
        var actualValues = collectOutput(from: publisher, during: interval, while: executing)
        if next, !actualValues.isEmpty {
            actualValues.removeFirst()
        }
        // swiftlint:disable:next prefer_nimble
        XCTAssertTrue(
            actualValues.isEmpty,
            "expected no values but got \(actualValues)",
            file: file,
            line: line
        )
    }
}
