//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import Streams
import XCTest

final class MediaSelectionTests: TestCase {
    func testCharacteristicsAndOptions() {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible, .legible]))
        expect(player.mediaSelectionOptions(for: .audible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
        expect(player.selectedMediaOption(for: .audible)).to(beNil())
    }

    // TODO: Test change in playlists as well
}
