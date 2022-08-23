//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

/// Borrowed from https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/
extension XCTestCase {
    /// Await for a publisher to complete and return its output.
    ///
    /// Remark: For never-ending publishers use `.first()`, `.collect()`, `.collectNext()`,
    ///         `collectFirst()` or similar to have the publisher complete after having
    ///         received the desired number of items.
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

    /// Collect values emitted by a publisher during some interval and return them.
    func collectPublisher<P: Publisher>(
        _ publisher: P,
        during interval: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) -> [P.Output] {
        var values: [P.Output] = []
        let expectation = self.expectation(description: "Collecting publisher values for \(interval) seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            expectation.fulfill()
        }

        let cancellable = publisher.sink(
            receiveCompletion: { _ in
            },
            receiveValue: { value in
                values.append(value)
            }
        )

        if let executing {
            executing()
        }

        waitForExpectations(timeout: interval + 1)
        cancellable.cancel()

        return values
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
