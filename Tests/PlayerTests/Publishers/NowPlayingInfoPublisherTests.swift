//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import MediaPlayer
import PillarboxCircumspect
import PillarboxStreams

final class NowPlayingInfoPublisherTests: TestCase {
    func testEmpty() {
        let player = Player()
        expectSimilarPublished(
            values: [[:]],
            from: player.nowPlayingInfoMetadataPublisher(),
            during: .milliseconds(100)
        )
    }

    func testImmediatelyAvailableWithoutMetadata() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expectSimilarPublished(
            values: [[:]],
            from: player.nowPlayingInfoMetadataPublisher(),
            during: .milliseconds(100)
        )
    }

    func testAvailableAfterDelay() {
        let player = Player(
            item: .mock(url: Stream.onDemand.url, loadedAfter: 0.1, withMetadata: AssetMetadataMock(title: "title"))
        )
        expectSimilarPublished(
            values: [[:], [MPMediaItemPropertyTitle: "title"]],
            from: player.nowPlayingInfoMetadataPublisher(),
            during: .milliseconds(200)
        )
    }

    func testImmediatelyAvailableWithMetadata() {
        let player = Player(item: .mock(
            url: Stream.onDemand.url,
            loadedAfter: 0,
            withMetadata: AssetMetadataMock(
                title: "title",
                subtitle: "subtitle"
            )
        ))
        expectSimilarPublished(
            values: [
                [:],
                [
                    MPMediaItemPropertyTitle: "title",
                    MPMediaItemPropertyArtist: "subtitle"
                ]
            ],
            from: player.nowPlayingInfoMetadataPublisher(),
            during: .milliseconds(200)
        )
    }

    func testUpdate() {
        let player = Player(item: .mock(url: Stream.onDemand.url, withMetadataUpdateAfter: 0.1))
        expectSimilarPublished(
            values: [
                [:],
                [
                    MPMediaItemPropertyTitle: "title0",
                    MPMediaItemPropertyArtist: "subtitle0"
                ],
                [
                    MPMediaItemPropertyTitle: "title1",
                    MPMediaItemPropertyArtist: "subtitle1"
                ]
            ],
            from: player.nowPlayingInfoMetadataPublisher(),
            during: .milliseconds(200)
        )
    }

    func testNetworkItemReloading() {
        let player = Player(item: .webServiceMock(media: .media1))
        expectAtLeastSimilarPublished(
            values: [
                [:],
                [
                    MPMediaItemPropertyTitle: "Title 1",
                    MPMediaItemPropertyArtist: "Subtitle 1"
                ]
            ],
            from: player.nowPlayingInfoMetadataPublisher()
        )
        expectSimilarPublishedNext(
            values: [
                [:],
                [
                    MPMediaItemPropertyTitle: "Title 2",
                    MPMediaItemPropertyArtist: "Subtitle 2"
                ]
            ],
            from: player.nowPlayingInfoMetadataPublisher(),
            during: .milliseconds(100)
        ) {
            player.items = [.webServiceMock(media: .media2)]
        }
    }

    func testEntirePlayback() {
        let player = Player(item: .mock(url: Stream.shortOnDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectSimilarPublished(
            values: [[:], [MPMediaItemPropertyTitle: "title"], [:]],
            from: player.nowPlayingInfoMetadataPublisher(),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testInactive() {
        let player = Player(item: .mock(url: Stream.onDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectSimilarPublished(
            values: [[:]],
            from: player.nowPlayingInfoPublisher(),
            during: .milliseconds(100)
        )
    }

    func testToggleActive() {
        let player = Player(item: .mock(url: Stream.onDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectAtLeastSimilarPublished(
            values: [[:], [MPNowPlayingInfoPropertyIsLiveStream: false]],
            from: player.nowPlayingInfoPublisher()
        ) {
            player.isActive = true
        }

        expectSimilarPublishedNext(
            values: [[:]],
            from: player.nowPlayingInfoPublisher(),
            during: .milliseconds(100)
        ) {
            player.isActive = false
        }
    }
}
