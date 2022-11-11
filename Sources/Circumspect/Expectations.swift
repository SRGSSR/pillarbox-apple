//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Difference
import XCTest

// swiftlint:disable prefer_nimble

public extension XCTestCase {
    /// Wait for a publisher to emit at least a list of expected values.
    func expectAtLeastPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never {
        expectAtLeastPublished(
            next: false,
            values: values,
            from: publisher,
            to: satisfy,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Wait for a publisher to emit at least a list of expected values.
    func expectAtLeastEqualPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Equatable {
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

    /// Wait for a publisher to emit at least a list of expected values.
    func expectAtLeastSimilarPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Similar {
        expectAtLeastPublished(
            values: values,
            from: publisher,
            to: ~=,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Wait for a publisher to emit at least a list of expected values, ignoring the first value. Useful when testing
    /// publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectAtLeastPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never {
        expectAtLeastPublished(
            next: true,
            values: values,
            from: publisher,
            to: satisfy,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Wait for a publisher to emit at least a list of expected values, ignoring the first value. Useful when testing
    /// publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectAtLeastEqualPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Equatable {
        expectAtLeastPublished(
            next: true,
            values: values,
            from: publisher,
            to: ==,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Wait for a publisher to emit at least a list of expected values, ignoring the first value. Useful when testing
    /// publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectAtLeastSimilarPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Similar {
        expectAtLeastPublished(
            next: true,
            values: values,
            from: publisher,
            to: ~=,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    private func expectAtLeastPublished<P: Publisher>(
        next: Bool,
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        while executing: (() -> Void)?
    ) where P.Failure == Never {
        precondition(!values.isEmpty)
        guard let actualValues = try? waitForOutput(
            from: next ? publisher.collectNext(values.count) : publisher.collectFirst(values.count),
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        ).flatMap({ $0 }) else {
            XCTFail("No values were published", file: file, line: line)
            return
        }

        let assertExpression = {
            guard actualValues.count == values.count else { return false }
            return zip(actualValues, values).allSatisfy { satisfy($0, $1) }
        }()
        XCTAssert(
            assertExpression,
            diff(values, actualValues).joined(separator: ", "),
            file: file,
            line: line
        )
    }
}

public extension XCTestCase {
    /// Expect a publisher to emit a list of expected values and complete.
    func expectOnlyPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        timeout: TimeInterval = 10,
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
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expect a publisher to emit a list of expected values and complete.
    func expectOnlyEqualPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: TimeInterval = 10,
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
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Similar {
        expectOnlyPublished(
            values: values,
            from: publisher,
            to: ~=,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expect a publisher to emit a list of expected values and complete, ignoring the first value. Useful when testing
    /// publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectOnlyPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        timeout: TimeInterval = 10,
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
        timeout: TimeInterval = 10,
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
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Similar {
        expectOnlyPublished(
            next: true,
            values: values,
            from: publisher,
            to: ~=,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    private func expectOnlyPublished<P: Publisher>(
        next: Bool,
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        timeout: TimeInterval,
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
        XCTAssert(
            assertExpression,
            diff(values, actualValues).joined(separator: ", "),
            file: file,
            line: line
        )
    }
}

public extension XCTestCase {
    /// Collect values emitted by a publisher during some time interval and match them against an expected result.
    func expectPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        during interval: TimeInterval,
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
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collect values emitted by a publisher during some time interval and match them against an expected result.
    func expectEqualPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: TimeInterval,
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
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collect values emitted by a publisher during some time interval and match them against an expected result.
    func expectSimilarPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Similar {
        expectPublished(
            next: false,
            values: values,
            from: publisher,
            to: ~=,
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collect values emitted by a publisher during some time interval and match them against an expected result,
    /// ignoring the first value. Useful when testing publishers which automatically deliver a non-relevant stored
    /// value upon subscription.
    func expectPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        during interval: TimeInterval,
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
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collect values emitted by a publisher during some time interval and match them against an expected result,
    /// ignoring the first value. Useful when testing publishers which automatically deliver a non-relevant stored
    /// value upon subscription.
    func expectEqualPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: TimeInterval,
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
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collect values emitted by a publisher during some time interval and match them against an expected result,
    /// ignoring the first value. Useful when testing publishers which automatically deliver a non-relevant stored
    /// value upon subscription.
    func expectSimilarPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never, P.Output: Similar {
        expectPublished(
            next: true,
            values: values,
            from: publisher,
            to: ~=,
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }

    private func expectPublished<P: Publisher>(
        next: Bool,
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        during interval: TimeInterval,
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
        XCTAssert(
            assertExpression,
            diff(values, actualValues).joined(separator: ", "),
            file: file,
            line: line
        )
    }
}

public extension XCTestCase {
    /// Ensure a publisher does not emit any value during some time interval.
    func expectNothingPublished<P: Publisher>(
        from publisher: P,
        during interval: TimeInterval,
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
        during interval: TimeInterval,
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
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P.Failure == Never {
        var actualValues = collectOutput(from: publisher, during: interval, while: executing)
        if next, !actualValues.isEmpty {
            actualValues.removeFirst()
        }
        XCTAssertTrue(
            actualValues.isEmpty,
            "expected no values but got \(actualValues)",
            file: file,
            line: line
        )
    }
}

public extension XCTestCase {
    /// Expect a publisher to complete successfully.
    func expectSuccess<P: Publisher>(
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        let expectation = expectation(description: "Waiting for publisher success")
        let cancellable = publisher.sink { completion in
            switch completion {
            case .finished:
                break
            case let .failure(error):
                XCTFail("The publisher incorrectly failed with error: \(error)", file: file, line: line)
            }
            expectation.fulfill()
        } receiveValue: { _ in
        }
        defer {
            cancellable.cancel()
        }

        if let executing {
            executing()
        }

        waitForExpectations(timeout: timeout)
    }

    /// Expect a publisher to complete with a failure.
    func expectFailure<P: Publisher>(
        _ error: Error? = nil,
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        let expectation = expectation(description: "Waiting for publisher failure")
        let cancellable = publisher.sink { completion in
            switch completion {
            case .finished:
                XCTFail("The publisher incorrectly succeeded", file: file, line: line)
            case let .failure(actualError):
                if let error {
                    XCTAssertEqual(error as NSError, actualError as NSError, file: file, line: line)
                }
            }
            expectation.fulfill()
        } receiveValue: { _ in
        }
        defer {
            cancellable.cancel()
        }

        if let executing {
            executing()
        }

        waitForExpectations(timeout: timeout)
    }
}

/// Remark: Nimble provides support for notifications but its collector is not thread-safe and might crash during
///         collection.
public extension XCTestCase {
    /// Wait until a list of notifications has been received.
    func expectReceived(
        notifications: [Notification],
        for names: Set<Notification.Name>,
        object: AnyObject? = nil,
        center: NotificationCenter = .default,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        expectAtLeastPublished(
            values: notifications,
            from: Publishers.MergeMany(
                names.map { center.publisher(for: $0, object: object) }
            ),
            to: ==,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collect notifications during some time interval and match them against an expected result.
    func expectReceived(
        notifications: [Notification],
        for names: Set<Notification.Name>,
        object: AnyObject? = nil,
        center: NotificationCenter = .default,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        expectPublished(
            values: notifications,
            from: Publishers.MergeMany(
                names.map { center.publisher(for: $0, object: object) }
            ),
            to: ==,
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Ensure no notifications are emitted during some time interval.
    func expectNoNotifications(
        for names: Set<Notification.Name>,
        object: AnyObject? = nil,
        center: NotificationCenter = .default,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        expectNothingPublished(
            from: Publishers.MergeMany(
                names.map { center.publisher(for: $0, object: object) }
            ),
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }
}

// swiftlint:enable prefer_nimble
