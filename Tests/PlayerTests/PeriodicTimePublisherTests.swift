//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import XCTest

final class PeriodicTimePublishersTests: XCTestCase {
    func testUnlimitedDemand() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        player.play()
        try expectPublisher(
            player.periodicTimePublisher(forInterval: CMTimeMake(value: 1, timescale: 2))
                .removeDuplicates(),
            values: [
                CMTimeMake(value: 0, timescale: 2),
                CMTimeMake(value: 1, timescale: 2),
                CMTimeMake(value: 2, timescale: 2),
                CMTimeMake(value: 3, timescale: 2),
                CMTimeMake(value: 4, timescale: 2),
                CMTimeMake(value: 5, timescale: 2)
            ],
            toBe: close(within: 0.1))
    }
}
