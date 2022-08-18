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
        try expectPublisher(player.periodicTimePublisher(forInterval: CMTimeMake(value: 1, timescale: 1)), values: [
            CMTimeMake(value: 0, timescale: 1),
            CMTimeMake(value: 1, timescale: 1),
            CMTimeMake(value: 2, timescale: 1)
        ])
    }
}
