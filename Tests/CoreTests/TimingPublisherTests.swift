//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import PillarboxCircumspect
import XCTest

final class TimingPublisherTests: XCTestCase {
    func testMeasureWithSingleEvent() {
        let publisher = Just(1)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .measureTiming()
            .map { $0.timeInterval() }
        expectAtLeastPublished(values: [0.5], from: publisher, to: beClose(within: 0.1))
    }

    func testMeasureWithMultipleEvents() {
        let publisher = [1, 2].publisher
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .measureTiming()
            .map { $0.timeInterval() }
        expectAtLeastPublished(values: [0.5, 0], from: publisher, to: beClose(within: 0.1))
    }

    func testMeasureWithoutEvents() {
        let publisher = Empty<Int, Never>()
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .measureTiming()
            .map { $0.timeInterval() }
        expectNothingPublished(from: publisher, during: .seconds(1))
    }

    func testAddWithSingleEvent() {
        let publisher = Just(1)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .addTiming()
            .map { $1.timeInterval() }
        expectAtLeastPublished(values: [0.5], from: publisher, to: beClose(within: 0.1))
    }

    func testAddWithMultipleEvents() {
        let publisher = [1, 2].publisher
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .addTiming()
            .map { $1.timeInterval() }
        expectAtLeastPublished(values: [0.5, 0], from: publisher, to: beClose(within: 0.1))
    }

    func testAddWithoutEvents() {
        let publisher = Empty<Int, Never>()
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .addTiming()
            .map { $1.timeInterval() }
        expectNothingPublished(from: publisher, during: .seconds(1))
    }
}
