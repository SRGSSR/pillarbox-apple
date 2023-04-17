//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

public extension XCTestCase {
    /// Expect a publisher to emit a list of expected values and complete.
    func expectOnlyPublished<P: Publisher, T>(
        values: [T],
        from publisher: P,
        to satisfy: @escaping (P.Output, T) -> Bool,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never {
        expectOnlyPublished(
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

    /// Expect a publisher to emit a list of expected values and complete.
    func expectOnlyEqualPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Equatable {
        expectOnlyPublished(
            values: values,
            from: publisher,
            to: ==,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expect a publisher to emit a list of expected values and complete.
    func expectOnlySimilarPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Similar {
        expectOnlyPublished(
            values: values,
            from: publisher,
            to: ~~,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expect a publisher to emit a list of expected values and complete, ignoring the first value. Useful when testing
    /// publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectOnlyPublishedNext<P: Publisher, T>(
        values: [T],
        from publisher: P,
        to satisfy: @escaping (P.Output, T) -> Bool,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never {
        expectOnlyPublished(
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

    /// Expect a publisher to emit a list of expected values and complete, ignoring the first value. Useful when testing
    /// publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectOnlyEqualPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Equatable {
        expectOnlyPublished(
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

    /// Expect a publisher to emit a list of expected values and complete, ignoring the first value. Useful when testing
    /// publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectOnlySimilarPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Similar {
        expectOnlyPublished(
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
    private func expectOnlyPublished<P: Publisher, T>(
        next: Bool,
        values: [T],
        from publisher: P,
        to satisfy: @escaping (P.Output, T) -> Bool,
        timeout: DispatchTimeInterval,
        assertDescription: ([T], [P.Output]) -> String,
        file: StaticString,
        line: UInt,
        while executing: (() -> Void)?
    ) where P.Failure == Never {
        precondition(!values.isEmpty)
        guard let actualValues = try? waitForOutput(
            from: next ? publisher.dropFirst().eraseToAnyPublisher() : publisher.eraseToAnyPublisher(),
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        ) else {
            XCTFail("No values were produced", file: file, line: line)
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
