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
        let item = Resource.simple(url: Stream.onDemand.url).playerItem(configuration: .default, limits: .none)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp)
        )
    }

    func testLoadingPlayerItem() {
        let item = Resource.loading.playerItem(configuration: .default, limits: .none)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp)
        )
    }

    func testFailingPlayerItem() {
        let item = Resource.failing(error: StructError()).playerItem(configuration: .default, limits: .none)
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown],
            from: item.statusPublisher(),
            during: .seconds(1)
        )
    }
}
