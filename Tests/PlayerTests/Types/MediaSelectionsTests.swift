//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import Streams
import XCTest

final class MediaSelectionsTests: TestCase {
    func testEmpty() {
        let mediaSelections = MediaSelections.empty
        expect(mediaSelections.characteristics).to(beEmpty())
        expect(mediaSelections.options(withMediaCharacteristic: .legible)).to(beEmpty())
    }

    func testCharacteristics() {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        expect(player.mediaSelections.characteristics).toEventually(equal([.audible, .legible]))
    }

    func testOptionsWithMediaCharacteristic() {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        expect(player.mediaSelections.characteristics).toEventuallyNot(beEmpty())
        expect(player.mediaSelections.options(withMediaCharacteristic: .legible)).notTo(beEmpty())
        expect(player.mediaSelections.options(withMediaCharacteristic: .visual)).to(beEmpty())
    }
}
