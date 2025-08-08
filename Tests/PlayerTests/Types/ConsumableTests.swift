//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble

final class ConsumableTests: TestCase {
    func testTake() {
        let consumable = Consumable(value: 1)
        expect(consumable.take()).to(equal(1))
    }

    func testConsecutiveTake() {
        let consumable = Consumable(value: 1)
        expect(consumable.take()).to(equal(1))
        expect(consumable.take()).to(beNil())
    }

    func testStore() {
        let consumable = Consumable(value: 1)
        consumable.store(2)
        expect(consumable.take()).to(equal(2))
    }
}
