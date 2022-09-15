//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import Nimble
import XCTest

@MainActor
final class ConfigurationTests: XCTestCase {
    func testDvrThreshold() {
        let item = AVPlayerItem(url: TestStreams.dvr.url)
        let player = Player(item: item) { configuration in
            configuration.dvrThreshold = CMTime(value: 30, timescale: 1)
        }
        expect(player.streamType).toEventually(equal(.live))
    }
}
