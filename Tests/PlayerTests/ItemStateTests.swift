//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

final class ItemStateTests: XCTestCase {
    func testEquality() {
        expect(ItemState.unknown).to(equal(.unknown))
        expect(ItemState.readyToPlay).to(equal(.readyToPlay))
        expect(ItemState.ended).to(equal(.ended))
        expect(ItemState.failed(error: StructError())).to(equal(.failed(error: StructError())))
    }

    func testInequality() {
        expect(ItemState.unknown).notTo(equal(.readyToPlay))
        expect(ItemState.failed(error: EnumError.error1)).notTo(equal(.failed(error: EnumError.error2)))
    }

    func testSimilarity() {
        expect(ItemState.unknown).to(equal(.unknown, by: ~=))
        expect(ItemState.readyToPlay).to(equal(.readyToPlay, by: ~=))
        expect(ItemState.ended).to(equal(.ended, by: ~=))
        expect(ItemState.failed(error: StructError())).to(equal(.failed(error: StructError()), by: ~=))
    }

    func testNoFriendlyComment() {
        expect(ItemState.friendlyComment(from: "The internet connection appears to be offline"))
            .to(equal("The internet connection appears to be offline"))
    }

    func testFriendlyComment() {
        expect(ItemState.friendlyComment(from: "The operation couldn’t be completed. (CoreBusiness.DataError error 1 - This content is not available anymore.)"))
            .to(equal("This content is not available anymore."))
        expect(ItemState.friendlyComment(from: "The operation couldn’t be completed. (CoreBusiness.DataError error 1 - Not found)"))
            .to(equal("Not found"))
        expect(ItemState.friendlyComment(from: "The operation couldn't be completed. (CoreMediaErrorDomain error -16839 - Unable to get playlist before long download timer.)"))
            .to(equal("Unable to get playlist before long download timer."))
    }
}
