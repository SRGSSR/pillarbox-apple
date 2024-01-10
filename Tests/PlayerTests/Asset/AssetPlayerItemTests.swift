//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxCircumspect
import PillarboxCoreBusiness
import PillarboxStreams

final class AssetPlayerItemTests: TestCase {
    func testNativePlayerItem() {
        let item = Asset.simple(url: Stream.onDemand.url).playerItem()
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp)
        )
    }

    func testLoadingPlayerItem() {
        let item = EmptyAsset.loading.playerItem()
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp)
        )
    }

    func testFailingPlayerItem() {
        let item = EmptyAsset.failed(error: StructError()).playerItem()
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [
                .unknown
            ],
            from: item.statePublisher(),
            during: .seconds(1)
        )
    }

    func testPlayerItemMetadata() {
        let item = Asset.simple(url: Stream.onDemand.url, metadata: AssetMetadataMock(title: "title")).playerItem()
        expect(item.externalMetadata.first!.commonKey!.rawValue).to(equal("title"))
    }
}
