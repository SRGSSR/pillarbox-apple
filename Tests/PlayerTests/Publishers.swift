//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

/// Borrowed from https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/
extension XCTestCase {
    enum AwaitError: Error {
        case unexpectedActivity
    }

    /// Await for a publisher to complete and return its output.
    /// Remark: For non-completing publishers use `.first()`, `.collect()`, `.collectNext()`,
    ///         `collectFirst()` or similar to have the publisher return values and complete.
    @discardableResult
    func awaitPublisher<P: Publisher>(
        _ publisher: P,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws -> P.Output {
        var result: Result<P.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    result = .failure(error)
                case .finished:
                    break
                }
                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        if let executing {
            executing()
        }

        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )
        return try unwrappedResult.get()
    }

    /// Expect a publisher not to emit.
    func notAwaitPublisher<P: Publisher>(
        _ publisher: P,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) throws where P.Failure == Never {
        let expectation = self.expectation(description: "Awaiting publisher not to emit for \(timeout) seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            expectation.fulfill()
        }

        var result: Result<P.Output, Error>?
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    result = .failure(error)
                case .finished:
                    break
                }
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        if let executing {
            executing()
        }

        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        guard result == nil else {
            throw AwaitError.unexpectedActivity
        }
    }
}

/// Borrowed from https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/
extension Published.Publisher {
    /// Collect the next number item before completing.
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Never> {
        dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}

extension Publisher where Failure == Never {
    /// Collect the specified number of items (including the current one) and completing.
    func collectFirst(_ count: Int) -> AnyPublisher<[Output], Never> {
        collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}
