//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import Nimble
import PillarboxCircumspect
import PillarboxStreams

// swiftlint:disable:next type_name
final class AVPlayerItemInitialPlaybackLikelyToKeepUpPublisherTests: TestCase {
    func testPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectSuccess(from: item.initialPlaybackLikelyToKeepUpPublisher())
    }

    func testError() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        _ = AVPlayer(playerItem: item)
        expectNothingPublished(
            from: item.initialPlaybackLikelyToKeepUpPublisher(),
            during: .milliseconds(500)
        )
    }
}
