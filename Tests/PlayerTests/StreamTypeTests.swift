//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

@MainActor
final class StreamTypeTests: XCTestCase {
    func testStartedOnDemandStream() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublished(
            values: [.unknown, .onDemand],
            from: player.$playbackProperties
                .map(\.streamType)
                .removeDuplicates()
        ) {
            player.play()
        }
    }

    func testNonStartedOnDemandStream() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublished(
            values: [.unknown, .onDemand],
            from: player.$playbackProperties
                .map(\.streamType)
                .removeDuplicates()
        )
    }
}
