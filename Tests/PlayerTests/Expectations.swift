//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Nimble
import XCTest

/// Defines similarity for types not conforming to `Equatable` and which need to be meaningfully compared in tests.
protocol Similar {
    static func ~= (lhs: Self, rhs: Self) -> Bool
}

extension XCTestCase {
    /// Expect a publisher to emit a list of values similar according to some criterium. Succeed as soon as the values have
    /// been received or throws if the expectation is not fulfilled.
    func expectPublisher<P: Publisher>(
        _ publisher: P,
        values: [P.Output],
        toBe similar: @escaping (P.Output, P.Output) -> Bool,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never {
        precondition(!values.isEmpty)
        let actualValues = try awaitPublisher(
            publisher.collectFirst(values.count),
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
        expect(actualValues).to(equal(values) { values1, values2 in
            guard values1.count == values2.count else { return false }
            return zip(values1, values2).allSatisfy { similar($0, $1) }
        })
    }

    /// Expect a publisher to emit an exact list of values according to some criterium during some time interval.
    func expectPublisher<P: Publisher>(
        _ publisher: P,
        values: [P.Output],
        toBe similar: @escaping (P.Output, P.Output) -> Bool,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never {
        let actualValues = collectPublisher(publisher, during: interval, while: executing)
        expect(actualValues).to(equal(values) { values1, values2 in
            guard values1.count == values2.count else { return false }
            return zip(values1, values2).allSatisfy { similar($0, $1) }
        })
    }

    /// Expect a publisher to emit a list of equatable values. Succeed as soon as the values have been received or
    /// throws if the expectation is not fulfilled
    func expectPublisher<P: Publisher>(
        _ publisher: P,
        values: [P.Output],
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Equatable {
        try expectPublisher(
            publisher,
            values: values,
            toBe: ==,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expect a publisher to emit an exact list of equatable values during some time interval.
    func expectPublisher<P: Publisher>(
        _ publisher: P,
        values: [P.Output],
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Equatable {
        try expectPublisher(
            publisher,
            values: values,
            toBe: ==,
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expect a publisher to emit a list of similar values. Succeed as soon as the values have been received or
    /// throws if the expectation is not fulfilled.
    func expectPublisher<P: Publisher>(
        _ publisher: P,
        values: [P.Output],
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Similar {
        try expectPublisher(
            publisher,
            values: values,
            toBe: ~=,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expect a publisher to emit an exact list of similar values during some time interval.
    func expectPublisher<P: Publisher>(
        _ publisher: P,
        values: [P.Output],
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never, P.Output: Similar {
        try expectPublisher(
            publisher,
            values: values,
            toBe: ~=,
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expect a `Published` property to emit a list of values. Succeed as soon as the values have been received or
    /// throws if the expectation is not fulfilled.
    func expectPublisher<T>(
        _ publisher: Published<T>.Publisher,
        values: [T],
        toBe similar: @escaping (T, T) -> Bool,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws {
        precondition(!values.isEmpty)
        let actualValues = try awaitPublisher(
            publisher.collectNext(values.count),        // Skip initial value
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
        expect(actualValues).to(equal(values) { values1, values2 in
            guard values1.count == values2.count else { return false }
            return zip(values1, values2).allSatisfy { similar($0, $1) }
        })
    }

    /// Expect a `Published` property to emit a list of equatable values. Succeed as soon as the values have been
    /// received or throws if the expectation is not fulfilled.
    func expectPublisher<T>(
        _ publisher: Published<T>.Publisher,
        values: [T],
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where T: Equatable {
        try expectPublisher(
            publisher,
            values: values,
            toBe: ==,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expect a `Published` property to emit a list of similar values. Succeed as soon as the values have been
    /// received or throws if the expectation is not fulfilled.
    func expectPublisher<T>(
        _ publisher: Published<T>.Publisher,
        values: [T],
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where T: Similar {
        try expectPublisher(
            publisher,
            values: values,
            toBe: ~=,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expect that a publisher does not emit any value during some time interval.
    func expectNoValuesFromPublisher<P: Publisher>(
        _ publisher: P,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never {
        let actualValues = collectPublisher(publisher, during: interval, while: executing)
        expect(actualValues).to(beEmpty())
    }
}

/// Remark: Nimble provides support for notifications but its collector is not thread-safe and crashes during
///         collection. We thus need to roll our own solution.
extension XCTestCase {
    /// Expect a list of notifications to be received, comparing the emitted values according to some criterium.
    /// Succeed as soon as the values have been received or throws if the expectation is not fulfilled.
    func expectNotifications(
        _ names: [Notification.Name],
        values: [Notification],
        toBe similar: @escaping (Notification, Notification) -> Bool,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws {
        try expectPublisher(
            Publishers.MergeMany(
                // Register once per notification (registration order does not matter)
                Set(names).map { NotificationCenter.default.publisher(for: $0) }
            ),
            values: values,
            toBe: similar,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Expect a list of notifications to be received. Succeed as soon as the notifications have been received or
    /// throws if the expectation is not fulfilled.
    func expectNotifications(
        _ names: [Notification.Name],
        values: [Notification],
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws {
        try expectNotifications(
            names,
            values: values,
            toBe: ==,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }
}
