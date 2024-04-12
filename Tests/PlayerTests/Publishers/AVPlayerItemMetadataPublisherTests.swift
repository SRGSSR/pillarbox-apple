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

final class AVPlayerItemMetadataPublisherTests: TestCase {
    func testItemWithOutput() {
        let item = AVPlayerItem(url: Stream.onDemandWithForcedAndUnforcedLegibleOptions.url)
        let player = AVPlayer(playerItem: item)
        player.play()
        expectPublished(
            values: [0, 1],
            from: item.metadataOutputPublisher(),
            to: { actualValue, expectedValue in
                actualValue.count == expectedValue
            },
            during: .seconds(1)
        )
    }

    func testItemWithoutOutput() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        player.play()
        expectPublished(
            values: [0],
            from: item.metadataOutputPublisher(),
            to: { actualValue, expectedValue in
                actualValue.count == expectedValue
            },
            during: .seconds(1)
        )
    }

    func testItemWithChapters() {
        let item = AVPlayerItem(url: Stream.chaptersMp4.url)
        _ = AVPlayer(playerItem: item)
        expectPublished(
            values: [0, 4],
            from: item.chaptersPublisher(),
            to: { actualValue, expectedValue in
                actualValue.count == expectedValue
            },
            during: .seconds(1)
        )
    }

    func testItemWithoutChapters() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectPublished(
            values: [0],
            from: item.chaptersPublisher(),
            to: { actualValue, expectedValue in
                actualValue.count == expectedValue
            },
            during: .seconds(1)
        )
    }

    func testItemWithMetadata() {
        let item = AVPlayerItem(url: Stream.mp3.url)
        _ = AVPlayer(playerItem: item)
        expectPublished(
            values: [0, 6],
            from: item.metadataPublisher(),
            to: { actualValue, expectedValue in
                actualValue.count == expectedValue
            },
            during: .seconds(1)
        )
    }

    func testItemWithoutMetadata() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectPublished(
            values: [0],
            from: item.metadataPublisher(),
            to: { actualValue, expectedValue in
                actualValue.count == expectedValue
            },
            during: .seconds(1)
        )
    }
}
