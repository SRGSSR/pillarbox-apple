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
        expect(state.position(for: id)?.time).to(equal(.zero))
        expect(state.position(for: id)?.time).to(beNil())
    }

    func testPreserveWhenReadForDifferentId() {
        let state = ResumeState(position: at(.zero), id: UUID())
        expect(state.position(for: UUID())?.time).to(beNil())
    }
}
