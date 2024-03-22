//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import MediaPlayer
import PillarboxCircumspect
import PillarboxStreams

final class NowPlayingInfoMetadataPublisherTests: TestCase {
    private static func nowPlayingInfoMetadataPublisher(for player: Player) -> AnyPublisher<NowPlayingInfo, Never> {
        player.$metadata
            .map(\.mediaItemInfo)
            // TODO: Should we have equality / remove duplicate performed in Player.Metadata stream?
            .removeDuplicates { lhs, rhs in
                // swiftlint:disable:next legacy_objc_type
                NSDictionary(dictionary: lhs).isEqual(to: rhs)
            }
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = Player()
        expectSimilarPublished(
            values: [[:]],
            from: Self.nowPlayingInfoMetadataPublisher(for: player),
            during: .milliseconds(500)
        )
    }

    func testImmediatelyAvailableWithoutMetadata() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expectSimilarPublished(
            values: [[:]],
            from: Self.nowPlayingInfoMetadataPublisher(for: player),
            during: .milliseconds(500)
        )
    }

    func testAvailableAfterDelay() {
        let player = Player(
            item: .mock(url: Stream.onDemand.url, loadedAfter: 0.5, withMetadata: AssetMetadataMock(title: "title"))
        )
        expectSimilarPublished(
            values: [[:], [MPMediaItemPropertyTitle: "title"]],
            from: Self.nowPlayingInfoMetadataPublisher(for: player),
            during: .milliseconds(500)
        )
    }

    func testImmediatelyAvailableWithMetadata() {
        let player = Player(item: .mock(
            url: Stream.onDemand.url,
            loadedAfter: 0,
            withMetadata: AssetMetadataMock(
                title: "title",
                subtitle: "subtitle",
                description: "description"
            )
        ))
        expectSimilarPublished(
            values: [
                [:],
                [
                    MPMediaItemPropertyTitle: "title",
                    MPMediaItemPropertyArtist: "subtitle",
                    MPMediaItemPropertyComments: "description"
                ]
            ],
            from: Self.nowPlayingInfoMetadataPublisher(for: player),
            during: .milliseconds(100)
        )
    }

    func testUpdate() {
        let player = Player(item: .mock(url: Stream.onDemand.url, withMetadataUpdateAfter: 0.1))
        expectAtLeastSimilarPublished(
            values: [
                [:],
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
            from: Self.nowPlayingInfoMetadataPublisher(for: player)
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
            from: Self.nowPlayingInfoMetadataPublisher(for: player)
        )
        expectAtLeastSimilarPublishedNext(
            values: [
                [:],
                [
                    MPMediaItemPropertyTitle: "Title 2",
                    MPMediaItemPropertyArtist: "Subtitle 2",
                    MPMediaItemPropertyComments: "Description 2"
                ]
            ],
            from: Self.nowPlayingInfoMetadataPublisher(for: player)
        ) {
            player.items = [.webServiceMock(media: .media2)]
        }
    }

    func testEntirePlayback() {
        let player = Player(item: .mock(url: Stream.shortOnDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectAtLeastSimilarPublished(
            values: [[:], [MPMediaItemPropertyTitle: "title"], [:]],
            from: Self.nowPlayingInfoMetadataPublisher(for: player)
        ) {
            player.play()
        }
    }

    func testError() {
        let player = Player(item: .mock(url: Stream.unavailable.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectAtLeastSimilarPublished(
            values: [
                [:],
                [
                    MPMediaItemPropertyTitle: "title"
                ],
                [
                    MPMediaItemPropertyTitle: "title",
                    MPMediaItemPropertyArtist: "The requested URL was not found on this server."
                ]
            ],
            from: Self.nowPlayingInfoMetadataPublisher(for: player)
        ) {
            player.play()
        }
    }

    // TODO: This test does not belong here since metadata is always published, even if inactive
    func testActive() {
        let player = Player(item: .mock(url: Stream.onDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectAtLeastSimilarPublished(
            values: [[:], [MPMediaItemPropertyTitle: "title"]],
            from: Self.nowPlayingInfoMetadataPublisher(for: player)
        ) {
            player.isActive = true
        }

        expectAtLeastSimilarPublished(
            values: [[MPMediaItemPropertyTitle: "title"], [:]],
            from: Self.nowPlayingInfoMetadataPublisher(for: player)
        ) {
            player.isActive = false
        }
    }
}
