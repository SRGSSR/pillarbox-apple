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
}

extension MeasurePublisherTests {
    func testWithSingleEvent() {
        let publisher = Just(1)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .measureDateInterval()
            .map(\.duration)
        expectPublished(values: [0.5], from: publisher, to: beClose(within: 0.1), during: .seconds(1))
    }

    func testWithMultipleEvents() {
        let publisher = [1, 2].publisher
            .flatMap { value in
                Just(value)
                    .delay(for: .milliseconds(value * 200), scheduler: DispatchQueue.main)
            }
            .measureDateInterval()
            .map(\.duration)
        expectPublished(values: [0.2, 0.2], from: publisher, to: beClose(within: 0.1), during: .seconds(1))
    }

    func testWithoutEvents() {
        expectNothingPublished(
            from: Empty<Int, Never>().measureDateInterval(),
            during: .seconds(1)
        )
    }
}

extension MeasurePublisherTests {
    func testClosureWithSingleEvent() {
        let expectation = expectation(description: "Done")
        Just(1)
            .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .measureDateInterval { interval in
                expect(interval.duration).to(beCloseTo(0.2, within: 0.1))
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
            .flatMap { value in
                Just(value)
                    .delay(for: .milliseconds(value * 200), scheduler: DispatchQueue.main)
            }
            .measureDateInterval { interval in
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
        zip(durations, [0.2, 0.2]).forEach { duration, expected in
            expect(duration).to(beCloseTo(expected, within: 0.1))
        }
    }

    func testClosureWithoutEvent() {
        let expectation = expectation(description: "Done")
        Empty<Int, Never>()
            .measureDateInterval { _ in
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
            .measureDateInterval { _ in
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

extension MeasurePublisherTests {
    func testWhen() {
        let expectation = expectation(description: "Done")
        var durations: [TimeInterval] = []
        [1, 2, 3, 4, 5, 6].publisher
            .flatMap { value in
                Just(value)
                    .delay(for: .milliseconds(value * 100), scheduler: DispatchQueue.main)
            }
            .measureDateInterval { interval in
                durations.append(interval.duration)
            } when: { value in
                value.isMultiple(of: 2)
            }
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)

        expect(durations.count).to(equal(3))
        zip(durations, [0.2, 0.2, 0.2]).forEach { duration, expected in
            expect(duration).to(beCloseTo(expected, within: 0.1))
        }
    }

    func testFirstWhen() {
        let expectation = expectation(description: "Done")
        var durations: [TimeInterval] = []
        [1, 2, 3, 4, 5, 6].publisher
            .flatMap { value in
                Just(value)
                    .delay(for: .milliseconds(value * 100), scheduler: DispatchQueue.main)
            }
            .measureDateInterval { interval in
                durations.append(interval.duration)
            } firstWhen: { value in
                value.isMultiple(of: 2)
            }
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)

        expect(durations.count).to(equal(1))
        zip(durations, [0.2]).forEach { duration, expected in
            expect(duration).to(beCloseTo(expected, within: 0.1))
        }
    }
}
