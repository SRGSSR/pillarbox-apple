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
    func testPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        player.play()
        try expectPublisher(
            player.periodicTimePublisher(forInterval: CMTimeMake(value: 1, timescale: 2))
                .removeDuplicates(),            // Might provide duplicate values
            values: [
                CMTimeMake(value: 0, timescale: 2),
                CMTimeMake(value: 1, timescale: 2),
                CMTimeMake(value: 2, timescale: 2),
                CMTimeMake(value: 3, timescale: 2),
                CMTimeMake(value: 4, timescale: 2),
                CMTimeMake(value: 5, timescale: 2)
            ],
            toBe: close(within: 0.1)
        )
    }

    func testSeek() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .playing]) {
            player.play()
        }

        Task {
            await player.seek(
                to: CMTime(value: 3, timescale: 2),
                toleranceBefore: .zero,
                toleranceAfter: .zero
            )
        }
        try expectPublisher(
            player.periodicTimePublisher(forInterval: CMTimeMake(value: 1, timescale: 2))
                .removeDuplicates(),            // Might provide duplicate values
            values: [
                CMTimeMake(value: 3, timescale: 2),
                CMTimeMake(value: 4, timescale: 2),
                CMTimeMake(value: 5, timescale: 2),
                CMTimeMake(value: 6, timescale: 2)
            ],
            toBe: close(within: 0.1)
        )
    }

    // TODO:
    //  - Test without playing (no events; requires a way to check that a values are never emitted)
    //  - Test with pause
    //  - Test with item change
    //  - etc.
}
