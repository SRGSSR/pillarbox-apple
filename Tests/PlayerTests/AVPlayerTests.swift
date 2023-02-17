//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

final class AVPlayerTests: XCTestCase {
    func testStabilityAtStart() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toNever(equal(.dvr), pollInterval: .microseconds(1))
    }
}
