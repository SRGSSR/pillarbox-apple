//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

// Borrowed from https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/
extension XCTestCase {
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
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
}

extension Published.Publisher {
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Never> {
        return dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}

extension Publisher where Failure == Never {
    func collectFirst(_ count: Int) -> AnyPublisher<[Output], Never> {
        return collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}
