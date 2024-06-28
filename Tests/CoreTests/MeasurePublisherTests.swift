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

private struct MockedError: Error {}

final class MeasurePublisherTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testWithSingleEvent() {
        let publisher = Just(1)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .measureDateInterval()
            .map(\.duration)
        expectPublished(values: [0.5], from: publisher, to: beClose(within: 0.1), during: .seconds(1))
    }

    func testWithMultipleEvents() {
        let publisher = [1, 2].publisher
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .measureDateInterval()
            .map(\.duration)
        expectPublished(values: [0.5, 0], from: publisher, to: beClose(within: 0.1), during: .seconds(1))
    }

    func testWithoutEvents() {
        let publisher = Empty<Int, Never>()
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .measureDateInterval()
        expectNothingPublished(from: publisher, during: .seconds(1))
    }

    func testClosureWithSingleEvent() {
        let expectation = expectation(description: "Done")
        Just(1)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .measure { interval in
                expect(interval.duration).to(beCloseTo(0.5, within: 0.1))
                expectation.fulfill()
            }
            .sink { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
    }

    func testClosureWithMultipleEvents() {
        let expectation = expectation(description: "Done")
        var durations: [TimeInterval] = []
        [1, 2].publisher
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .measure { interval in
                durations.append(interval.duration)
            }
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)

        expect(durations.count).to(equal(2))
        zip(durations, [0.5, 0]).forEach { duration, expected in
            expect(duration).to(beCloseTo(expected, within: 0.1))
        }
    }

    func testClosureWithoutEvent() {
        let expectation = expectation(description: "Done")
        Empty<Int, Never>()
            .measure { _ in
                fail("Must never be called")
            }
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 0.5)
    }

    func testClosureWithError() {
        let expectation = expectation(description: "Done")
        Fail<Int, Error>(error: MockedError())
            .measure { _ in
                fail("Must never be called")
            }
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 0.5)
    }
}
