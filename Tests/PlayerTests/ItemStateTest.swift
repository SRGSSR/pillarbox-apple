//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player
import AVFoundation
import Nimble
import XCTest

final class ItemStateTests: XCTestCase {
    private enum TestError: Error {
        case message1
        case message2
    }

    func testSimpleEquality() {
        expect(Player.ItemState.unknown).to(equal(.unknown))
        expect(Player.ItemState.readyToPlay).to(equal(.readyToPlay))
        expect(Player.ItemState.ended).to(equal(.ended))
    }

    func testFailureEquality() {
        expect(Player.ItemState.failed(error: TestError.message1)).to(equal(.failed(error: TestError.message1)))
    }

    func testSimpleInequality() {
        expect(Player.ItemState.unknown).notTo(equal(.readyToPlay))
        expect(Player.ItemState.readyToPlay).notTo(equal(.failed(error: TestError.message1)))
    }

    func testFailureInequality() {
        expect(Player.ItemState.failed(error: TestError.message1)).notTo(equal(.failed(error: TestError.message2)))
    }
}
