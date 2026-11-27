//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Combine
import Foundation
import Nimble
import PillarboxPlayer
import PillarboxStreams

private enum UpdateComScoreMetadataAssetLoader: AssetLoader {
    static func metadataPublisher(for input: URL) -> AnyPublisher<[String: String], any Error> {
        Just(["meta": "initial"])
            .append(Just(["meta": "updated"]).delay(for: 6, scheduler: DispatchQueue.main))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(from input: URL, metadata: [String: String]) -> Asset {
        .simple(url: input)
    }

    // swiftlint:disable:next discouraged_optional_collection
    static func playerMetadata(from input: URL, metadata: [String: String]?) -> PlayerMetadata {
        .empty
    }
}

final class ComScoreTrackerMetadataTests: ComScoreTestCase {
    func testMetadata() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in
                    ["meta_1": "custom-1", "meta_2": "42"]
                },
            ]
        ))

        expectAtLeastHits(
            play { labels in
                expect(labels["meta_1"]).to(equal("custom-1"))
                expect(labels["meta_2"]).to(equal(42))
                expect(labels["cs_ucfr"]).to(beEmpty())
            }
        ) {
            player.play()
        }
    }

    func testEmptyMetadata() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in [:] }
            ]
        ))

        expectNoHits(during: .milliseconds(500)) {
            player.play()
        }
    }

    func testNoMetadata() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in [:] }
            ]
        ))

        expectNoHits(during: .milliseconds(500)) {
            player.play()
        }
    }

    func testNoEventsOnMetadataUpdate() {
        let player = Player(item: .init(
            assetLoaderType: UpdateComScoreMetadataAssetLoader.self,
            input: Stream.onDemand.url,
            trackerAdapters: [ComScoreTracker.adapter { $0 }]
        ))

        expectHits(play(), during: .seconds(7)) {
            player.play()
        }
    }
}
