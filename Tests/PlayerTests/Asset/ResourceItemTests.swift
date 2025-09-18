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

final class ResourceItemTests: TestCase {
    private static func isPlaybackLikelyToKeepUpPublisher(for item: AVPlayerItem) -> AnyPublisher<Bool, Never> {
        item.publisher(for: \.isPlaybackLikelyToKeepUp)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testNativePlayerItem() {
        let item = Resource.simple(url: Stream.onDemand.url).playerItem(configuration: .default)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true],
            from: Self.isPlaybackLikelyToKeepUpPublisher(for: item)
        )
    }

    func testLoadingPlayerItem() {
        let item = Resource.loading.playerItem(configuration: .default)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false],
            from: Self.isPlaybackLikelyToKeepUpPublisher(for: item)
        )
    }

    func testFailingPlayerItem() {
        let item = Resource.failing(error: StructError()).playerItem(configuration: .default)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown],
            from: item.statusPublisher()
        )
    }
}
