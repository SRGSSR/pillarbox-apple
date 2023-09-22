//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Streams
import XCTest

final class AVPlayerItemErrorPublisherTests: TestCase {
    func testValidStream() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectNothingPublished(from: item.errorPublisher(), during: .seconds(1))
    }

    func testPlaybackFailure() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [PlayerError.resourceNotFound],
            from: item.errorPublisher(),
            to: beEqual
        )
    }

    func testCorruptStream() {
        let item = AVPlayerItem(url: Stream.corruptOnDemand.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [PlayerError.segmentNotFound],
            from: item.errorPublisher(),
            to: beEqual
        )
    }
}

private func beEqual(_ lhsError: Error, _ rhsError: Error) -> Bool {
    lhsError as NSError == rhsError as NSError
}
