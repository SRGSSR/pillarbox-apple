//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import OrderedCollections
import XCTest

final class QueuePlayerInvalidSeekTests: XCTestCase {
    func testNotificationsForSeekWithInvalidTime() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect { player.seek(to: .invalid) }.to(throwAssertion())
    }
}
