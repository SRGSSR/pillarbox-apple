//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Foundation
import Nimble

final class ResumeStateTests: TestCase {
    func testDestroyWhenReadForSameId() {
        let id = UUID()
        let state = ResumeState(position: at(.zero), id: id)
        expect(state.isEmpty).to(beFalse())
        expect(state.position(for: id)?.time).to(equal(.zero))
        expect(state.isEmpty).to(beTrue())
    }

    func testPreserveWhenReadForDifferentId() {
        let state = ResumeState(position: at(.zero), id: UUID())
        expect(state.isEmpty).to(beFalse())
        expect(state.position(for: UUID())?.time).to(beNil())
        expect(state.isEmpty).to(beFalse())
    }
}
