//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

final class StreamTypeTests: XCTestCase {
    func testOnDemandStream() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        try expectPublisher(player.$properties.map(\.streamType), values: [.onDemand])
    }
}
