//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

/// Ideas borrowed from https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/
public extension XCTestCase {
    /// Wait for a publisher to complete and return its result.
    /// - Parameters:
    ///   - publisher: Publisher to monitor.
    ///   - timeout: Timeout after which the expectation fails.
    ///   - file: File where the expectation is made.
    ///   - line: Line where the expectation is made.
    ///   - executing: Code which must be executed while waiting on the expectation.
    /// - Returns: The result of the publisher.
    @discardableResult
    func waitForResult<P: Publisher>(
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws -> Result<[P.Output], P.Failure> {
        var values: [P.Output] = []
        var result: Result<[P.Output], P.Failure>?

        let expectation = expectation(description: "Waiting for publisher output")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    result = .failure(error)
                case .finished:
                    result = .success(values)
                }
                expectation.fulfill()
            },
            receiveValue: { value in
                values.append(value)
            }
        )
        defer {
            cancellable.cancel()
        }

        if let executing {
            executing()
        }

        waitForExpectations(timeout: timeout)
        return try XCTUnwrap(result, "The publisher did not produce any result", file: file, line: line)
    }

    /// Wait for a publisher to complete and return its output.
    /// - Parameters:
    ///   - publisher: Publisher to monitor.
    ///   - timeout: Timeout after which the expectation fails.
    ///   - file: File where the expectation is made.
    ///   - line: Line where the expectation is made.
    ///   - executing: Code which must be executed while waiting on the expectation.
    /// - Returns: The collected output.
    @discardableResult
    func waitForOutput<P: Publisher>(
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws -> [P.Output] {
        let result = try waitForResult(
            from: publisher,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
        return try result.get()
    }

    /// Wait for a publisher to complete with a single output. Fails if not the case.
    /// - Parameters:
    ///   - publisher: Publisher to monitor.
    ///   - timeout: Timeout after which the expectation fails.
    ///   - file: File where the expectation is made.
    ///   - line: Line where the expectation is made.
    ///   - executing: Code which must be executed while waiting on the expectation.
    /// - Returns: The output.
    @discardableResult
    func waitForSingleOutput<P: Publisher>(
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws -> P.Output {
        let output = try waitForOutput(
            from: publisher,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
        guard output.count == 1, let singleOutput = output.first else {
            XCTFail("The publisher did not produce one and only one output", file: file, line: line)
            throw ExpectationError.incorrectResult
        }
        return singleOutput
    }

    /// Wait for a publisher to complete with a failure. Fails if not the case.
    /// - Parameters:
    ///   - publisher: Publisher to monitor.
    ///   - timeout: Timeout after which the expectation fails.
    ///   - file: File where the expectation is made.
    ///   - line: Line where the expectation is made.
    ///   - executing: Code which must be executed while waiting on the expectation.
    /// - Returns: The failure reason.
    @discardableResult
    func waitForFailure<P: Publisher>(
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws -> P.Failure {
        let result = try waitForResult(
            from: publisher,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
        switch result {
        case .success:
            XCTFail("The publisher incorrectly succeeded", file: file, line: line)
            throw ExpectationError.incorrectResult
        case let .failure(error):
            return error
        }
    }

    /// Collect output emitted by a publisher during some interval.
    /// - Parameters:
    ///   - publisher: Publisher to monitor.
    ///   - interval: Timeout after which the expectation fails.
    ///   - file: File where the expectation is made.
    ///   - line: Line where the expectation is made.
    ///   - executing: Code which must be executed while waiting on the expectation.
    /// - Returns: The collected output.
    func collectOutput<P: Publisher>(
        from publisher: P,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) -> [P.Output] {
        var values: [P.Output] = []

        let expectation = expectation(description: "Collecting publisher output for \(interval) seconds")
        let cancellable = publisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { value in
                values.append(value)
            }
        )
        defer {
            cancellable.cancel()
        }

        if let executing {
            executing()
        }

        _ = XCTWaiter.wait(for: [expectation], timeout: interval)
        return values
    }
}

public extension Publisher where Failure == Never {
    /// Collect the specified number of items (including the current one) before completing.
    func collectFirst(_ count: Int) -> AnyPublisher<[Output], Never> {
        collect(count)
            .first()
            .eraseToAnyPublisher()
    }

    /// Collect the next number of items before completing.
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Never> {
        dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}
