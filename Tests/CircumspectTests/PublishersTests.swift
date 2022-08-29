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
    func testCollectFirst() {
        let values = waitForOutput(
            from: [1, 2, 3, 4, 5].publisher.collectFirst(3)
        ).flatMap { $0 }
        expect(values).to(equal([1, 2, 3]))
    }

    func testCollectNext() {
        let values = waitForOutput(
            from: [1, 2, 3, 4, 5].publisher.collectNext(3)
        ).flatMap { $0 }
        expect(values).to(equal([2, 3, 4]))
    }

    func testwaitForOutput() {
        let values = waitForOutput(from: [1, 2, 3].publisher)
        expect(values).to(equal([1, 2, 3]))
    }

    func testwaitForOutputWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        let values = waitForOutput(from: subject) {
            subject.send(4)
            subject.send(7)
            subject.send(completion: .finished)
        }
        expect(values).to(equal([4, 7]))
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
