//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Nimble
import XCTest

/// Defines similarity for types not conforming to `Equatable` and which need to be meaningfully comparable.
protocol Similar {
    static func ~= (lhs: Self, rhs: Self) -> Bool
}

extension XCTestCase {
    /// Expect a publisher to emit a list of values.
    func expectPublisher<P: Publisher>(
        _ publisher: P,
        values: [P.Output],
        toBe similar: @escaping (P.Output, P.Output) -> Bool,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never {
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

    /// Expect a publisher to emit a list of equatable values.
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

    /// Expect a publisher to emit a list of similar values.
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

    /// Expect a `Published` property to emit a list of values.
    func expectPublisher<T>(
        _ publisher: Published<T>.Publisher,
        values: [T],
        toBe similar: @escaping (T, T) -> Bool,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws {
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

    /// Expect a `Published` property to emit a list of equatable values.
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

    /// Expect a `Published` property to emit a list of similar values.
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
}
