//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import PillarboxCircumspect
import XCTest

final class MeasurePublisherTests: XCTestCase {
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
}
