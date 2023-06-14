//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

public extension XCTestCase {
    /// Collects values emitted by a publisher during some time interval and matches them against an expected result.
    func expectPublished<P: Publisher, T>(
        values: [T],
        from publisher: P,
        to satisfy: @escaping (P.Output, T) -> Bool,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never {
        expectPublished(
            next: false,
            values: values,
            from: publisher,
            to: satisfy,
            during: interval,
            assertDescription: AssertDescription.difference,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collects values emitted by a publisher during some time interval and matches them against an expected result.
    func expectEqualPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Equatable {
        expectPublished(
            next: false,
            values: values,
            from: publisher,
            to: ==,
            during: interval,
            assertDescription: AssertDescription.difference,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collects values emitted by a publisher during some time interval and matches them against an expected result.
    func expectSimilarPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Similar {
        expectPublished(
            next: false,
            values: values,
            from: publisher,
            to: ~~,
            during: interval,
            assertDescription: AssertDescription.difference,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collects values emitted by a publisher during some time interval and matches them against an expected result,
    /// ignoring the first value.
    ///
    /// Useful when testing publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectPublishedNext<P: Publisher, T>(
        values: [T],
        from publisher: P,
        to satisfy: @escaping (P.Output, T) -> Bool,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never {
        expectPublished(
            next: true,
            values: values,
            from: publisher,
            to: satisfy,
            during: interval,
            assertDescription: AssertDescription.difference,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collects values emitted by a publisher during some time interval and matches them against an expected result,
    /// ignoring the first value.
    ///
    /// Useful when testing publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectEqualPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Equatable {
        expectPublished(
            next: true,
            values: values,
            from: publisher,
            to: ==,
            during: interval,
            assertDescription: AssertDescription.difference,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collects values emitted by a publisher during some time interval and matches them against an expected result,
    /// ignoring the first value.
    ///
    /// Useful when testing publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectSimilarPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Similar {
        expectPublished(
            next: true,
            values: values,
            from: publisher,
            to: ~~,
            during: interval,
            assertDescription: AssertDescription.difference,
            file: file,
            line: line,
            while: executing
        )
    }

    private func expectPublished<P: Publisher, T>(
        next: Bool,
        values: [T],
        from publisher: P,
        to satisfy: @escaping (P.Output, T) -> Bool,
        during interval: DispatchTimeInterval = .seconds(20),
        assertDescription: ([T], [P.Output]) -> String,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never {
        var actualValues = collectOutput(from: publisher, during: interval, while: executing)
        if next, !actualValues.isEmpty {
            actualValues.removeFirst()
        }
        let assertExpression = {
            guard actualValues.count == values.count else { return false }
            return zip(actualValues, values).allSatisfy { satisfy($0, $1) }
        }()
        // swiftlint:disable:next prefer_nimble
        XCTAssert(
            assertExpression,
            assertDescription(values, actualValues),
            file: file,
            line: line
        )
    }
}
