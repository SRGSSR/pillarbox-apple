//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Foundation

final class PlayerItemTrackerTests: TestCase {
    func testPlayerItemLifecycle() {
        expectAtLeastEqualPublished(values: [.initialized, .deinitialized], from: TrackerVoidMock.state) {
            _ = PlayerItem.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [
                    TrackerVoidMock.adapter()
                ]
            )
        }
    }

    func testItemPlayback() {
        let player = Player()
        expectEqualPublished(values: [.initialized, .enabled], from: TrackerVoidMock.state, during: .seconds(2)) {
            player.append(.simple(
                url: Stream.onDemand.url,
                trackerAdapters: [
                    TrackerVoidMock.adapter()
                ]
            ))
            player.play()
        }
    }

    func testItemEntirePlayback() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled], from: TrackerVoidMock.state) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [
                    TrackerVoidMock.adapter()
                ]
            ))
            player.play()
        }
    }

    func testFailedItem() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled], from: TrackerVoidMock.state) {
            player.append(.simple(
                url: Stream.unavailable.url,
                trackerAdapters: [
                    TrackerVoidMock.adapter()
                ]
            ))
            player.play()
        }
    }

    func testMetadata() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .updated("title"), .disabled], from: TrackerMock.state) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                metadata: AssetMetadataMock(title: "title"),
                trackerAdapters: [
                    TrackerMock.adapter { $0.title }
                ]
            ))
            player.play()
        }
    }

    func testMetadataUpdate() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .updated("title0"), .updated("title1"), .disabled], from: TrackerMock.state) {
            player.append(.mock(url: Stream.shortOnDemand.url, withMetadataUpdateAfter: 1, trackerAdapters: [
                TrackerMock.adapter { $0.title }
            ]))
            player.play()
        }
    }
}
