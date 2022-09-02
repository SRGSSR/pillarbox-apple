//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Circumspect

import Combine
import Nimble
import XCTest

final class PublisherTests: XCTestCase {
    func testSuccessResult() {
        let values = try? waitForResult(from: [1, 2, 3, 4, 5].publisher).get()
        expect(values).to(equal([1, 2, 3, 4, 5]))
    }

    func testSuccessResultWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        let values = try? waitForResult(from: subject) {
            subject.send(4)
            subject.send(7)
            subject.send(completion: .finished)
        }.get()
        expect(values).to(equal([4, 7]))
    }

    func testFailureResult() {
        let values = try? waitForResult(from: Fail<Int, Error>(error: TestError.any)).get()
        expect(values).to(beNil())
    }

    func testCollectFirst() throws {
        let values = try waitForOutput(
            from: [1, 2, 3, 4, 5].publisher.collectFirst(3)
        ).flatMap { $0 }
        expect(values).to(equal([1, 2, 3]))
    }

    func testCollectNext() throws {
        let values = try waitForOutput(
            from: [1, 2, 3, 4, 5].publisher.collectNext(3)
        ).flatMap { $0 }
        expect(values).to(equal([2, 3, 4]))
    }

    func testWaitForOutput() throws {
        let values = try waitForOutput(from: [1, 2, 3].publisher)
        expect(values).to(equal([1, 2, 3]))
    }

    func testWaitForOutputWhileExecuting() throws {
        let subject = PassthroughSubject<Int, Never>()
        let values = try waitForOutput(from: subject) {
            subject.send(4)
            subject.send(7)
            subject.send(completion: .finished)
        }
        expect(values).to(equal([4, 7]))
    }

    func testWaitForFailure() throws {
        let error = try waitForFailure(from: Fail<Int, Error>(error: TestError.any))
        expect(error).notTo(beNil())
    }

    func testWaitForFailureWhileExecuting() throws {
        let subject = PassthroughSubject<Int, Error>()
        let error = try waitForFailure(from: Fail<Int, Error>(error: TestError.any)) {
            subject.send(4)
            subject.send(7)
            subject.send(completion: .failure(TestError.any))
        }
        expect(error).notTo(beNil())
    }

    func testCollectOutput() {
        let counter = Counter()
        let values = collectOutput(from: counter.$count, during: 0.5)
        expect(values).to(equal([0, 1, 2]))
    }

    func testCollectOutputWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        let values = collectOutput(from: subject, during: 0.5) {
            subject.send(4)
            subject.send(7)
        }
        expect(values).to(equal([4, 7]))
    }

    func testCollectImmediateOutput() {
        let values = collectOutput(
            from: [1, 2, 3, 4, 5].publisher,
            during: 0
        )
        expect(values).to(equal([1, 2, 3, 4, 5]))
    }
}
