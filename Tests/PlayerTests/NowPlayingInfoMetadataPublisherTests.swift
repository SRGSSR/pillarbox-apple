//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import MediaPlayer
import XCTest

final class NowPlayingInfoMetadataPublisherTests: XCTestCase {
    func testEmpty() {
        let player = Player()
        expectAtLeastSimilarPublished(
            values: [nil],
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

    func testImmediatelyAvailableWithMetadata() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: .init(
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
        let player = Player(item: .metadataUpdate(url: Stream.onDemand.url, delay: 1))
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
}
