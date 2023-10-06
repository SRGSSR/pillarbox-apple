//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

// Ideas borrowed from https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/

public extension XCTestCase {
    /// Waits for a publisher to complete and returns its result.
    @discardableResult
    func waitForResult<P>(
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws -> Result<[P.Output], P.Failure> where P: Publisher {
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

        waitForExpectations(timeout: timeout.double())
        return try XCTUnwrap(result, "The publisher did not produce any result", file: file, line: line)
    }

    /// Waits for a publisher to complete and returns its output.
    @discardableResult
    func waitForOutput<P>(
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws -> [P.Output] where P: Publisher {
        let result = try waitForResult(
            from: publisher,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
        return try result.get()
    }

    /// Waits for a publisher to complete with a single output. Fails if not the case.
    @discardableResult
    func waitForSingleOutput<P>(
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws -> P.Output where P: Publisher {
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

    /// Waits for a publisher to complete with a failure. Fails if not the case.
    @discardableResult
    func waitForFailure<P>(
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws -> P.Failure where P: Publisher {
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

    /// Collects output emitted by a publisher during some interval.
    func collectOutput<P>(
        from publisher: P,
        during interval: DispatchTimeInterval = .seconds(20),
        while executing: (() -> Void)? = nil
    ) -> [P.Output] where P: Publisher {
        var values: [P.Output] = []
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

        _ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: interval.double())
        return values
    }
}

public extension Publisher where Failure == Never {
    /// Collects the specified number of items (including the current one) before completing.
    func collectFirst(_ count: Int) -> AnyPublisher<[Output], Never> {
        collect(count)
            .first()
            .eraseToAnyPublisher()
    }

    /// Collects the next number of items before completing.
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Never> {
        dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}
