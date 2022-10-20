//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Core

import Circumspect
import Combine
import XCTest

final class PublisherTests: XCTestCase {
    static func publisher(at index: Int) -> AnyPublisher<Int, Never> {
        precondition(index > 0)
        return Just(index)
            .delay(for: .seconds(Double(index) * 0.1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    static func prependedPublisher(at index: Int) -> AnyPublisher<Int, Never> {
        precondition(index > 0)
        return Just(index)
            .delay(for: .seconds(Double(index) * 0.1), scheduler: DispatchQueue.main)
            .prepend(0)
            .eraseToAnyPublisher()
    }

    func testAccumulateOne() {
        expectOnlyEqualPublished(
            values: [
                [1]
            ],
            from: Publishers.AccumulateLatestMany(
                Self.publisher(at: 1)
            )
        )
    }

    func testAccumulateTwo() {
        expectOnlyEqualPublished(
            values: [
                [1, 2]
            ],
            from: Publishers.AccumulateLatestMany(
                Self.publisher(at: 1),
                Self.publisher(at: 2)
            )
        )
    }

    func testAccumulateThree() {
        expectOnlyEqualPublished(
            values: [
                [1, 2, 3]
            ],
            from: Publishers.AccumulateLatestMany(
                Self.publisher(at: 1),
                Self.publisher(at: 2),
                Self.publisher(at: 3)
            )
        )
    }

    func testAccumulateFour() {
        expectOnlyEqualPublished(
            values: [
                [1, 2, 3, 4]
            ],
            from: Publishers.AccumulateLatestMany(
                Self.publisher(at: 1),
                Self.publisher(at: 2),
                Self.publisher(at: 3),
                Self.publisher(at: 4)
            )
        )
    }

    func testAccumulateFive() {
        expectOnlyEqualPublished(
            values: [
                [1, 2, 3, 4, 5]
            ],
            from: Publishers.AccumulateLatestMany(
                Self.publisher(at: 1),
                Self.publisher(at: 2),
                Self.publisher(at: 3),
                Self.publisher(at: 4),
                Self.publisher(at: 5)
            )
        )
    }

    func testAccumulateOnePrepended() {
        expectOnlyEqualPublished(
            values: [
                [0],
                [1]
            ],
            from: Publishers.AccumulateLatestMany(
                Self.prependedPublisher(at: 1)
            )
        )
    }

    func testAccumulateTwoPrepended() {
        expectOnlyEqualPublished(
            values: [
                [0, 0],
                [1, 0],
                [1, 2]
            ],
            from: Publishers.AccumulateLatestMany(
                Self.prependedPublisher(at: 1),
                Self.prependedPublisher(at: 2)
            )
        )
    }

    func testAccumulateThreePrepended() {
        expectOnlyEqualPublished(
            values: [
                [0, 0, 0],
                [1, 0, 0],
                [1, 2, 0],
                [1, 2, 3]
            ],
            from: Publishers.AccumulateLatestMany(
                Self.prependedPublisher(at: 1),
                Self.prependedPublisher(at: 2),
                Self.prependedPublisher(at: 3)
            )
        )
    }

    func testAccumulateFourPrepended() {
        expectOnlyEqualPublished(
            values: [
                [0, 0, 0, 0],
                [1, 0, 0, 0],
                [1, 2, 0, 0],
                [1, 2, 3, 0],
                [1, 2, 3, 4]
            ],
            from: Publishers.AccumulateLatestMany(
                Self.prependedPublisher(at: 1),
                Self.prependedPublisher(at: 2),
                Self.prependedPublisher(at: 3),
                Self.prependedPublisher(at: 4)
            )
        )
    }

    func testAccumulateFivePrepended() {
        expectOnlyEqualPublished(
            values: [
                [0, 0, 0, 0, 0],
                [1, 0, 0, 0, 0],
                [1, 2, 0, 0, 0],
                [1, 2, 3, 0, 0],
                [1, 2, 3, 4, 0],
                [1, 2, 3, 4, 5]
            ],
            from: Publishers.AccumulateLatestMany(
                Self.prependedPublisher(at: 1),
                Self.prependedPublisher(at: 2),
                Self.prependedPublisher(at: 3),
                Self.prependedPublisher(at: 4),
                Self.prependedPublisher(at: 5)
            )
        )
    }
}
