//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCircumspect

import Combine
import Nimble
import XCTest

final class PublisherTests: XCTestCase {
    func testWaitForSuccessResult() {
        let values = try? waitForResult(from: [1, 2, 3, 4, 5].publisher).get()
        expect(values).to(equal([1, 2, 3, 4, 5]))
    }

    func testWaitForSuccessResultWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        let values = try? waitForResult(from: subject) {
            subject.send(4)
            subject.send(7)
            subject.send(completion: .finished)
        }.get()
        expect(values).to(equal([4, 7]))
    }

    func testWaitForFailureResult() {
        let values = try? waitForResult(from: Fail<Int, Error>(error: StructError())).get()
        expect(values).to(beNil())
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

    func testWaitForSingleOutput() throws {
        let value = try waitForSingleOutput(from: [1].publisher)
        expect(value).to(equal(1))
    }

    func testWaitForSingleOutputWhileExecuting() throws {
        let subject = PassthroughSubject<Int, Never>()
        let value = try waitForSingleOutput(from: subject) {
            subject.send(4)
            subject.send(completion: .finished)
        }
        expect(value).to(equal(4))
    }

    func testWaitForFailure() throws {
        let error = try waitForFailure(from: Fail<Int, Error>(error: StructError()))
        expect(error).notTo(beNil())
    }

    func testWaitForFailureWhileExecuting() throws {
        let subject = PassthroughSubject<Int, Error>()
        let error = try waitForFailure(from: Fail<Int, Error>(error: StructError())) {
            subject.send(4)
            subject.send(7)
            subject.send(completion: .failure(StructError()))
        }
        expect(error).notTo(beNil())
    }

    func testCollectOutput() {
        let counter = Counter()
        let values = collectOutput(from: counter.$count, during: .milliseconds(500))
        expect(values).to(equal([0, 1, 2]))
    }

    func testCollectOutputWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        let values = collectOutput(from: subject, during: .milliseconds(500)) {
            subject.send(4)
            subject.send(7)
        }
        expect(values).to(equal([4, 7]))
    }

    func testCollectOutputImmediately() {
        let values = collectOutput(
            from: [1, 2, 3, 4, 5].publisher,
            during: .never
        )
        expect(values).to(equal([1, 2, 3, 4, 5]))
    }

    func testCollectFirst() throws {
        let values = try waitForOutput(
            from: [1, 2, 3, 4, 5].publisher.collectFirst(3)
        ).flatMap(\.self)
        expect(values).to(equal([1, 2, 3]))
    }

    func testCollectNext() throws {
        let values = try waitForOutput(
            from: [1, 2, 3, 4, 5].publisher.collectNext(3)
        ).flatMap(\.self)
        expect(values).to(equal([2, 3, 4]))
    }
}
