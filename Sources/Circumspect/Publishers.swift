//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

/// Borrowed from https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/
public extension XCTestCase {
    /// Await for a publisher to complete and return its collected output.
    ///
    /// Remark: For never-ending publishers use `.first()`, `.collect()`, `.collectNext()`,
    ///         `collectFirst()` or similar to have the publisher complete after having
    ///         received the desired number of items.
    @discardableResult
    func awaitCompletion<P: Publisher>(
        from publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws -> [P.Output] {
        var values: [P.Output] = []
        var result: Result<[P.Output], Error>?

        let expectation = expectation(description: "Awaiting publisher")

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

        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )
        return try unwrappedResult.get()
    }

    /// Collect output emitted by a publisher during some interval.
    func collectOutput<P: Publisher>(
        from publisher: P,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) -> [P.Output] {
        var values: [P.Output] = []

        let expectation = expectation(description: "Collecting publisher values for \(interval) seconds")
        let cancellable = publisher.sink(
            receiveCompletion: { _ in
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
