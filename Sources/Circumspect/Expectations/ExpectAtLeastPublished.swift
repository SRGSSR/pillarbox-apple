//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

public extension XCTestCase {
    /// Expects a publisher to emit at least a list of expected values.
    func expectAtLeastPublished<P, T>(
        values: [T],
        from publisher: P,
        to satisfy: @escaping (P.Output, T) -> Bool,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P: Publisher, P.Failure == Never {
        expectAtLeastPublished(
            next: false,
            values: values,
            from: publisher,
            to: satisfy,
            timeout: timeout,
            assertDescription: AssertDescription.difference,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expects a publisher to emit at least a list of expected values.
    func expectAtLeastEqualPublished<P>(
        values: [P.Output],
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P: Publisher, P.Failure == Never, P.Output: Equatable {
        expectAtLeastPublished(
            values: values,
            from: publisher,
            to: ==,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expects a publisher to emit at least a list of expected values.
    func expectAtLeastSimilarPublished<P>(
        values: [P.Output],
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P: Publisher, P.Failure == Never, P.Output: Similar {
        expectAtLeastPublished(
            values: values,
            from: publisher,
            to: ~~,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expects a publisher to emit at least a list of expected values, ignoring the first value.
    ///
    /// Useful when testing publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectAtLeastPublishedNext<P, T>(
        values: [T],
        from publisher: P,
        to satisfy: @escaping (P.Output, T) -> Bool,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P: Publisher, P.Failure == Never {
        expectAtLeastPublished(
            next: true,
            values: values,
            from: publisher,
            to: satisfy,
            timeout: timeout,
            assertDescription: AssertDescription.difference,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expects a publisher to emit at least a list of expected values, ignoring the first value.
    ///
    /// Useful when testing publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectAtLeastEqualPublishedNext<P>(
        values: [P.Output],
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P: Publisher, P.Failure == Never, P.Output: Equatable {
        expectAtLeastPublished(
            next: true,
            values: values,
            from: publisher,
            to: ==,
            timeout: timeout,
            assertDescription: AssertDescription.difference,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expects a publisher to emit at least a list of expected values, ignoring the first value.
    ///
    /// Useful when testing publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectAtLeastSimilarPublishedNext<P>(
        values: [P.Output],
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P: Publisher, P.Failure == Never, P.Output: Similar {
        expectAtLeastPublished(
            next: true,
            values: values,
            from: publisher,
            to: ~~,
            timeout: timeout,
            assertDescription: AssertDescription.difference,
            file: file,
            line: line,
            while: executing
        )
    }

    // swiftlint:disable:next function_parameter_count
    private func expectAtLeastPublished<P, T>(
        next: Bool,
        values: [T],
        from publisher: P,
        to satisfy: @escaping (P.Output, T) -> Bool,
        timeout: DispatchTimeInterval,
        assertDescription: ([T], [P.Output]) -> String,
        file: StaticString,
        line: UInt,
        while executing: (() -> Void)?
    ) where P: Publisher, P.Failure == Never {
        precondition(!values.isEmpty)
        guard let actualValues = try? waitForOutput(
            from: next ? publisher.collectNext(values.count) : publisher.collectFirst(values.count),
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        ).flatMap(\.self) else {
            XCTFail("Failed to publish enough values", file: file, line: line)
            return
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
