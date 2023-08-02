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
final class AVPlayerCurrentItemMediaSelectionGroupPublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectEqualPublished(
            values: [nil],
            from: player.currentItemMediaSelectionGroupPublisher(for: .audible),
            during: .seconds(2)
        )
    }

    func testPlayback() {
        let item = AVPlayerItem(url: Stream.onDemandWithTracks.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [nil, 3],
            from: player.currentItemMediaSelectionGroupPublisher(for: .audible).map { $0?.options.count },
            during: .seconds(2)
        )
    }

    func testFailure() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [nil],
            from: player.currentItemMediaSelectionGroupPublisher(for: .audible).map { $0?.options.count },
            during: .seconds(2)
        )
    }
}
