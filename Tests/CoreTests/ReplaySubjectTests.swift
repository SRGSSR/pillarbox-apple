//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import PillarboxCircumspect
import XCTest

final class ReplaySubjectTests: XCTestCase {
    func testEmptyBufferOfZero() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 0)
        expectNothingPublished(from: subject, during: .milliseconds(100))
    }

    func testEmptyBufferOfTwo() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        expectNothingPublished(from: subject, during: .milliseconds(100))
    }

    func testFilledBufferOfZero() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 0)
        subject.send(1)
        expectNothingPublished(from: subject, during: .milliseconds(100))
    }

    func testFilledBufferOfTwo() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        subject.send(1)
        subject.send(2)
        subject
            .send(3)
        expectEqualPublished(values: [2, 3], from: subject, during: .milliseconds(100))
    }

    func testNewValuesWithBufferOfZero() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 0)
        subject.send(1)
        expectEqualPublished(values: [2, 3], from: subject, during: .milliseconds(100)) {
            subject.send(2)
            subject.send(3)
        }
    }

    func testNewValuesWithBufferOfTwo() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        subject.send(1)
        subject.send(2)
        subject.send(3)
        expectEqualPublished(values: [2, 3, 4, 5], from: subject, during: .milliseconds(100)) {
            subject.send(4)
            subject.send(5)
        }
    }

    func testMultipleSubscribers() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        subject.send(1)
        subject.send(2)
        subject.send(3)
        expectEqualPublished(values: [2, 3], from: subject, during: .milliseconds(100))
        expectEqualPublished(values: [2, 3], from: subject, during: .milliseconds(100))
    }

    func testNewValuesWithMultipleSubscribers() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        subject.send(1)
        subject.send(2)
        subject.send(3)
        expectEqualPublished(values: [2, 3, 4], from: subject, during: .milliseconds(100)) {
            subject.send(4)
        }
        expectEqualPublished(values: [3, 4], from: subject, during: .milliseconds(100))
    }

    func testCompletion() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        expectOnlyEqualPublished(values: [1], from: subject) {
            subject.send(1)
            subject.send(completion: .finished)
        }
    }

    func testNoValueAfterCompletion() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        subject.send(1)
        subject.send(completion: .finished)
        subject.send(2)
        expectEqualPublished(values: [1], from: subject, during: .milliseconds(100))
    }

    func testCompletionWithMultipleSubscribers() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        expectOnlyEqualPublished(values: [1], from: subject) {
            subject.send(1)
            subject.send(completion: .finished)
        }
        expectOnlyEqualPublished(values: [1], from: subject)
    }

    func testNoMoreValuesThanRequested() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 4)

        subject.send(1)
        subject.send(2)
        subject.send(3)
        subject.send(4)

        var results = [Int]()
        var completed = false

        let subscriber = AnySubscriber<Int, Never>(
            receiveSubscription: { subscription in
                subscription.request(.max(3))
            },
            receiveValue: { results.append($0); return .none },
            receiveCompletion: { _ in }
        )

        subject
            .subscribe(subscriber)

        XCTAssertEqual(results, [1, 2, 3])
    }
}