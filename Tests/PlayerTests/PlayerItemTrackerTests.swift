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
        expectAtLeastEqualPublished(values: [.initialized, .deinitialized], from: SimpleTrackerMock.state) {
            _ = PlayerItem.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [SimpleTrackerMock.adapter()]
            )
        }
    }

    func testItemPlayback() {
        let player = Player()
        expectEqualPublished(values: [.initialized, .enabled], from: SimpleTrackerMock.state, during: .seconds(2)) {
            player.append(.simple(
                url: Stream.onDemand.url,
                trackerAdapters: [SimpleTrackerMock.adapter()]
            ))
            player.play()
        }
    }

    func testItemEntirePlayback() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled], from: SimpleTrackerMock.state) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [SimpleTrackerMock.adapter()]
            ))
            player.play()
        }
    }

    func testNetworkLoadedItemEntirePlayback() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled], from: SimpleTrackerMock.state) {
            player.append(.mock(
                url: Stream.shortOnDemand.url,
                loadedAfter: 1,
                trackerAdapters: [SimpleTrackerMock.adapter()]
            ))
            player.play()
        }
    }

    func testFailedItem() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled], from: SimpleTrackerMock.state) {
            player.append(.simple(
                url: Stream.unavailable.url,
                trackerAdapters: [SimpleTrackerMock.adapter()]
            ))
            player.play()
        }
    }

    func testMetadata() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .updated("title"), .disabled], from: NonConfigurableTrackerMock.state) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                metadata: AssetMetadataMock(title: "title"),
                trackerAdapters: [NonConfigurableTrackerMock.adapter { $0.title }]
            ))
            player.play()
        }
    }

    func testMetadataUpdate() {
        let player = Player()
        expectAtLeastEqualPublished(
            values: [.initialized, .enabled, .updated("title0"), .updated("title1"), .disabled],
            from: NonConfigurableTrackerMock.state
        ) {
            player.append(.mock(url: Stream.shortOnDemand.url, withMetadataUpdateAfter: 1, trackerAdapters: [
                NonConfigurableTrackerMock.adapter { $0.title }
            ]))
            player.play()
        }
    }

    func testConfiguration() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized("config"), .enabled, .disabled], from: MetadataFreeMock.state) {
            player.append(.mock(url: Stream.shortOnDemand.url, withMetadataUpdateAfter: 1, trackerAdapters: [
                MetadataFreeMock.adapter(configuration: "config")
            ]))
            player.play()
        }
    }

    func testConfigurationAndMetadataUpdate() {
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized("config"), .enabled, .updated("title"), .disabled], from: TrackerMock.state) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                metadata: AssetMetadataMock(title: "title"),
                trackerAdapters: [TrackerMock.adapter(configuration: "config") { $0.title }]
            ))
            player.play()
        }
    }
}
