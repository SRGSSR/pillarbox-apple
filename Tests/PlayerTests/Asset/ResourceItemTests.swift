//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import PillarboxCircumspect
import PillarboxStreams

final class ResourceItemTests: TestCase {
    func testNativePlayerItem() {
        let item = Resource.simple(url: Stream.onDemand.url).playerItem()
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp)
        )
    }

    func testLoadingPlayerItem() {
        let item = Resource.loading.playerItem()
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp)
        )
    }

    func testFailingPlayerItem() {
        let item = Resource.failing(error: StructError()).playerItem()
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown],
            from: item.statusPublisher(),
            during: .seconds(1)
        )
    }
}
