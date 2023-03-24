//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Foundation

final class PlayerItemTrackerTests: TestCase {
    func testWithInitialItem() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: TrackerVoidMock.state) {
            let player = Player(item: .simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [
                    TrackerVoidMock.adapter()
                ]
            ))
            player.play()
        }
    }

    func testWithoutInitialItem() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: TrackerVoidMock.state) {
            let player = Player()
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [
                    TrackerVoidMock.adapter()
                ]
            ))
            player.play()
        }
    }

    func testWithFailedItem() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: TrackerVoidMock.state) {
            let player = Player(item: .simple(
                url: Stream.unavailable.url,
                trackerAdapters: [
                    TrackerVoidMock.adapter()
                ]
            ))
            player.play()
        }
    }

    func testPlayerDeinit() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: TrackerVoidMock.state) {
            _ = Player(item: .simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [
                    TrackerVoidMock.adapter()
                ]
            ))
        }
    }

    func testPlayerItemDeinit() {
        expectAtLeastEqualPublished(values: [.initialized, .deinitialized], from: TrackerVoidMock.state) {
            _ = PlayerItem.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [
                    TrackerVoidMock.adapter()
                ]
            )
        }
    }

    func testMetadata() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .update("title"), .disabled], from: TrackerMock.state) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                metadata: LocalMetadata(title: "title"),
                trackerAdapters: [
                    TrackerMock.adapter { $0.title }
                ]
            ))
            player.play()
        }
    }

    func testMetadataUpdate() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .update("title0"), .update("title1"), .disabled], from: TrackerMock.state) {
            player.append(.updated(url: Stream.shortOnDemand.url, after: 1, trackerAdapters: [
                TrackerMock.adapter { $0.title }
            ]))
            player.play()
        }
    }
}
