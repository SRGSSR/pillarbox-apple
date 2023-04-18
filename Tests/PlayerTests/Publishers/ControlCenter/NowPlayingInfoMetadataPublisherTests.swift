//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import MediaPlayer
import Streams
import XCTest

final class NowPlayingInfoMetadataPublisherTests: TestCase {
    func testEmpty() {
        let player = Player()
        expectAtLeastSimilarPublished(
            values: [[:]],
            from: player.nowPlayingInfoMetadataPublisher()
        )
    }

    func testImmediatelyAvailableWithoutMetadata() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expectAtLeastSimilarPublished(
            values: [[:]],
            from: player.nowPlayingInfoMetadataPublisher()
        )
    }

    func testAvailableAfterDelay() {
        let player = Player(
            item: .mock(url: Stream.onDemand.url, loadedAfter: 0.5, withMetadata: AssetMetadataMock(title: "title"))
        )
        expectAtLeastSimilarPublished(
            values: [[:], [MPMediaItemPropertyTitle: "title"]],
            from: player.nowPlayingInfoMetadataPublisher()
        )
    }

    func testImmediatelyAvailableWithMetadata() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(
                title: "title",
                subtitle: "subtitle",
                description: "description"
            )
        ))
        expectAtLeastSimilarPublished(
            values: [
                [
                    MPMediaItemPropertyTitle: "title",
                    MPMediaItemPropertyArtist: "subtitle",
                    MPMediaItemPropertyComments: "description"
                ]
            ],
            from: player.nowPlayingInfoMetadataPublisher()
        )
    }

    func testUpdate() {
        let player = Player(item: .mock(url: Stream.onDemand.url, withMetadataUpdateAfter: 1))
        expectAtLeastSimilarPublished(
            values: [
                [
                    MPMediaItemPropertyTitle: "title0",
                    MPMediaItemPropertyArtist: "subtitle0",
                    MPMediaItemPropertyComments: "description0"
                ],
                [
                    MPMediaItemPropertyTitle: "title1",
                    MPMediaItemPropertyArtist: "subtitle1",
                    MPMediaItemPropertyComments: "description1"
                ]
            ],
            from: player.nowPlayingInfoMetadataPublisher()
        )
    }

    func testNetworkItemReloading() {
        let player = Player(item: .webServiceMock(media: .media1))
        expectAtLeastSimilarPublished(
            values: [
                [:],
                [
                    MPMediaItemPropertyTitle: "Title 1",
                    MPMediaItemPropertyArtist: "Subtitle 1",
                    MPMediaItemPropertyComments: "Description 1"
                ]
            ],
            from: player.nowPlayingInfoMetadataPublisher()
        )
        expectAtLeastSimilarPublishedNext(
            values: [
                [:],
                [
                    MPMediaItemPropertyTitle: "Title 1",
                    MPMediaItemPropertyArtist: "Subtitle 1",
                    MPMediaItemPropertyComments: "Description 1"
                ]
            ],
            from: player.nowPlayingInfoMetadataPublisher()
        ) {
            player.removeAllItems()
            player.append(.webServiceMock(media: .media1))
        }
    }

    func testEntirePlayback() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url, metadata: AssetMetadataMock(title: "title")))
        expectAtLeastSimilarPublished(
            values: [[MPMediaItemPropertyTitle: "title"], [:]],
            from: player.nowPlayingInfoMetadataPublisher()
        ) {
            player.play()
        }
    }
}
