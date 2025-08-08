//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble

final class ConsumableTests: TestCase {
    func testEmpty() {
        let consumable = Consumable<Int>()
        expect(consumable.isEmpty).to(beTrue())
    }

    func testNonEmpty() {
        let consumable = Consumable(value: 1)
        expect(consumable.isEmpty).to(beFalse())
    }

    func testTake() {
        let consumable = Consumable(value: 1)
        expect(consumable.take()).to(equal(1))
        expect(consumable.isEmpty).to(beTrue())
    }

    func testConsecutiveTake() {
        let consumable = Consumable(value: 1)
        expect(consumable.take()).to(equal(1))
        expect(consumable.take()).to(beNil())
    }

    func testStore() {
        let consumable = Consumable<Int>()
        consumable.store(2)
        expect(consumable.isEmpty).to(beFalse())
        expect(consumable.take()).to(equal(2))
    }
}
