//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

public extension XCTestCase {
    /// Ensure a publisher does not emit any value during some time interval.
    func expectNothingPublished<P: Publisher>(
        from publisher: P,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never {
        expectNothingPublished(
            next: false,
            from: publisher,
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Ensure a publisher does not emit any value during some time interval.
    func expectNothingPublishedNext<P: Publisher>(
        from publisher: P,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never {
        expectNothingPublished(
            next: true,
            from: publisher,
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }

    private func expectNothingPublished<P: Publisher>(
        next: Bool,
        from publisher: P,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never {
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
