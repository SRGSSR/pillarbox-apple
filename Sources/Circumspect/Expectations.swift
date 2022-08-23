//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

// swiftlint:disable prefer_nimble

/// Defines similarity for types not conforming to `Equatable` and which need to be meaningfully compared in tests.
public protocol Similar {
    /// Must return `true` iff the two sides can be considered to be similar.
    static func ~= (lhs: Self, rhs: Self) -> Bool
}

public extension XCTestCase {
    /// Wait for a publisher to emit a list of expected values.
    func expectPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never {
        try expectPublished(
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

    /// Wait for a publisher to emit a list of expected values.
    func expectPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Equatable {
        try expectPublished(
            values: values,
            from: publisher,
            to: ==,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Wait for a publisher to emit a list of expected values.
    func expectPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Similar {
        try expectPublished(
            values: values,
            from: publisher,
            to: ~=,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Wait for a publisher to emit a list of expected values, ignoring the first value. Useful when testing
    /// publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never {
        try expectPublished(
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

    /// Wait for a publisher to emit a list of expected values, ignoring the first value. Useful when testing
    /// publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Equatable {
        try expectPublished(
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

    /// Wait for a publisher to emit a list of expected values, ignoring the first value. Useful when testing
    /// publishers which automatically deliver a non-relevant stored value upon subscription.
    func expectPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Similar {
        try expectPublished(
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

    private func expectPublished<P: Publisher>(
        next: Bool,
        values: [P.Output],
        from publisher: P,
        to satisfy: @escaping (P.Output, P.Output) -> Bool,
        timeout: TimeInterval,
        file: StaticString,
        line: UInt,
        while executing: (() -> Void)?
    ) throws where P.Failure == Never {
        precondition(!values.isEmpty)
        let actualValues = try awaitCompletion(
            from: next ? publisher.collectNext(values.count) : publisher.collectFirst(values.count),
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
        let assertExpression = {
            guard actualValues.count == values.count else { return false }
            return zip(actualValues, values).allSatisfy { satisfy($0, $1) }
        }()
        let message = {
            "expected to equal \(values), got \(actualValues)"
        }()
        XCTAssert(assertExpression, message, file: file, line: line)
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
    ) throws where P.Failure == Never {
        try expectPublished(
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
    func expectPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Equatable {
        try expectPublished(
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
    func expectPublished<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Similar {
        try expectPublished(
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
    ) throws where P.Failure == Never {
        try expectPublished(
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
    func expectPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Equatable {
        try expectPublished(
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
    func expectPublishedNext<P: Publisher>(
        values: [P.Output],
        from publisher: P,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Similar {
        try expectPublished(
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
    ) throws where P.Failure == Never {
        var actualValues = collectOutput(from: publisher, during: interval, while: executing)
        if next {
            actualValues.removeFirst()
        }
        let assertExpression = {
            guard actualValues.count == values.count else { return false }
            return zip(actualValues, values).allSatisfy { satisfy($0, $1) }
        }()
        let message = {
            "expected to equal \(values), got \(actualValues)"
        }()
        XCTAssert(assertExpression, message, file: file, line: line)
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
    ) throws where P.Failure == Never {
        try expectNothingPublished(
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
    ) throws where P.Failure == Never {
        try expectNothingPublished(
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
    ) throws where P.Failure == Never {
        var actualValues = collectOutput(from: publisher, during: interval, while: executing)
        if next {
            actualValues.removeFirst()
        }
        let message = {
            "expected no values but got \(actualValues)"
        }()
        XCTAssertTrue(actualValues.isEmpty, message, file: file, line: line)
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
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws {
        try expectPublished(
            values: notifications,
            from: Publishers.MergeMany(
                names.map { NotificationCenter.default.publisher(for: $0, object: object) }
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
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws {
        try expectPublished(
            values: notifications,
            from: Publishers.MergeMany(
                names.map { NotificationCenter.default.publisher(for: $0, object: object) }
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
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws {
        try expectNothingPublished(
            from: Publishers.MergeMany(
                names.map { NotificationCenter.default.publisher(for: $0, object: object) }
            ),
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }
}

// swiftlint:enable prefer_nimble
