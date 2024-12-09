//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import Nimble
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
        subject.send(3)
        expectAtLeastEqualPublished(values: [2, 3], from: subject)
    }

    func testNewValuesWithBufferOfZero() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 0)
        subject.send(1)
        expectAtLeastEqualPublished(values: [2, 3], from: subject) {
            subject.send(2)
            subject.send(3)
        }
    }

    func testNewValuesWithBufferOfTwo() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        subject.send(1)
        subject.send(2)
        subject.send(3)
        expectAtLeastEqualPublished(values: [2, 3, 4, 5], from: subject) {
            subject.send(4)
            subject.send(5)
        }
    }

    func testMultipleSubscribers() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        subject.send(1)
        subject.send(2)
        subject.send(3)
        expectAtLeastEqualPublished(values: [2, 3], from: subject)
        expectAtLeastEqualPublished(values: [2, 3], from: subject)
    }

    func testSubscriptionRelease() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 1)
        subject.send(1)

        _ = subject.sink { _ in }

        expect(subject.subscriptions).to(beEmpty())
    }

    func testNewValuesWithMultipleSubscribers() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        subject.send(1)
        subject.send(2)
        subject.send(3)
        expectAtLeastEqualPublished(values: [2, 3, 4], from: subject) {
            subject.send(4)
        }
        expectAtLeastEqualPublished(values: [3, 4], from: subject)
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
        expectAtLeastEqualPublished(values: [1], from: subject)
    }

    func testCompletionWithMultipleSubscribers() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 2)
        expectOnlyEqualPublished(values: [1], from: subject) {
            subject.send(1)
            subject.send(completion: .finished)
        }
        expectOnlyEqualPublished(values: [1], from: subject)
    }

    func testRequestLessValuesThanAvailable() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 3)
        subject.send(1)
        subject.send(2)
        subject.send(3)

        var results = [Int]()
        subject
            .subscribe(AnySubscriber<Int, Never>(
                receiveSubscription: { subscription in
                    subscription.request(.max(2))
                },
                receiveValue: { value in
                    results.append(value)
                    return .none
                },
                receiveCompletion: { _ in }
            ))
        expect(results).to(equalDiff([1, 2]))
    }

    func testThreadSafety() {
        let replaySubject = ReplaySubject<Int, Never>(bufferSize: 3)
        for i in 0..<100 {
            DispatchQueue.global().async {
                replaySubject.send(i)
            }
        }
    }

    func testDeliveryOrderInRecursiveScenario() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 1)
        var cancellables = Set<AnyCancellable>()

        var values: [String] = []

        subject.sink { i in
            values.append("A\(i)")
        }
        .store(in: &cancellables)

        subject.sink { i in
            values.append("B\(i)")
            if i == 1 {
                subject.send(2)
            }
        }
        .store(in: &cancellables)

        subject.sink { i in
            values.append("C\(i)")
        }
        .store(in: &cancellables)

        subject.send(1)
        expect(values).to(equalDiff(["A1", "B1", "A2", "B2", "C1", "C2"]))
    }
}
