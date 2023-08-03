//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Streams
import XCTest

// swiftlint:disable:next type_name
final class AVPlayerCurrentItemmediaSelectionsPublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectEqualPublished(
            values: [0],
            from: player.currentItemMediaSelectionsPublisher().map(\.count),
            during: .seconds(2)
        )
    }

    func testPlayback() {
        let item = AVPlayerItem(url: Stream.onDemandWithTracks.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [0, 2],
            from: player.currentItemMediaSelectionsPublisher().map(\.count),
            during: .seconds(2)
        )
    }

    func testFailure() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [0],
            from: player.currentItemMediaSelectionsPublisher().map(\.count),
            during: .seconds(2)
        )
    }
}
