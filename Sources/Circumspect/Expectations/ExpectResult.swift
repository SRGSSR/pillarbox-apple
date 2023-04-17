//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

public extension XCTestCase {
    /// Expect a publisher to complete successfully.
    func expectSuccess<P: Publisher>(
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
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
        } receiveValue: { _ in }
        
        defer {
            cancellable.cancel()
        }

        if let executing {
            executing()
        }

        waitForExpectations(timeout: timeout.double())
    }

    /// Expect a publisher to complete with a failure.
    func expectFailure<P: Publisher>(
        _ error: Error? = nil,
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
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
                    // swiftlint:disable:next prefer_nimble
                    XCTAssertEqual(error as NSError, actualError as NSError, file: file, line: line)
                }
            }
            expectation.fulfill()
        } receiveValue: { _ in }

        defer {
            cancellable.cancel()
        }

        if let executing {
            executing()
        }

        waitForExpectations(timeout: timeout.double())
    }
}
