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
    func testEmpty() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 1)
        expectNothingPublished(from: subject, during: .milliseconds(100))
    }

    func testReplayWithEmptyBuffer() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 0)
        subject.send(1)
        expectEqualPublished(values: [2], from: subject, during: .milliseconds(100)) {
            subject.send(2)
        }
    }

    func testReplayWithFilledBufferOfOne() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 1)
        subject.send(1)
        expectEqualPublished(values: [1, 2], from: subject, during: .milliseconds(100)) {
            subject.send(2)
        }
    }

    func testReplayWithFilledBufferOfFour() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 4)
        subject.send(1)
        subject.send(2)
        subject.send(3)
        subject.send(4)
        subject.send(5)
        subject.send(6)
        subject.send(7)
        expectEqualPublished(values: [4, 5, 6, 7, 8], from: subject, during: .milliseconds(100)) {
            subject.send(8)
        }
    }

    func testReplayWithUnfilledBuffer() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 1)
        expectEqualPublished(values: [1], from: subject, during: .milliseconds(100)) {
            subject.send(1)
        }
    }

    func testMultipleSubscribers() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 1)
        subject.send(1)
        expectEqualPublished(values: [1], from: subject, during: .milliseconds(100))
        expectEqualPublished(values: [1], from: subject, during: .milliseconds(100))
    }

    func testMultipleSubscribersWithNewValues() {
        let subject = ReplaySubject<Int, Never>(bufferSize: 1)
        subject.send(1)
        expectEqualPublished(values: [1, 2], from: subject, during: .milliseconds(100)) {
            subject.send(2)
        }
        expectEqualPublished(values: [1, 2], from: subject, during: .milliseconds(100))
    }
}
