//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import PillarboxCircumspect
import PillarboxStreams

final class AVPlayerItemMetadataOutputPublisherTests: TestCase {
    func testOutput() {
        let item = AVPlayerItem(url: Stream.onDemandWithForcedAndUnforcedLegibleOptions.url)
        let player = AVPlayer(playerItem: item)
        player.play()
        expectAtLeastPublished(values: [1], from: item.metadataOutputPublisher()) { _, _ in
            true
        }
    }
}
