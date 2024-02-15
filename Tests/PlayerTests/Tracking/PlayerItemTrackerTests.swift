//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import PillarboxCircumspect
import PillarboxStreams

final class PlayerItemTrackerTests: TestCase {
    func testPlayerItemLifeCycle() {
        let publisher = NoMetadataTrackerMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .deinitialized], from: publisher.removeDuplicates()) {
            _ = PlayerItem.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [NoMetadataTrackerMock.adapter(statePublisher: publisher)]
            )
        }
    }

    func testItemPlayback() {
        let player = Player()
        let publisher = NoMetadataTrackerMock.StatePublisher()
        expectEqualPublished(values: [.initialized, .enabled, .properties], from: publisher.removeDuplicates(), during: .seconds(2)) {
            player.append(.simple(
                url: Stream.onDemand.url,
                trackerAdapters: [NoMetadataTrackerMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testItemEntirePlayback() {
        let player = Player()
        let publisher = NoMetadataTrackerMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .properties, .disabled], from: publisher.removeDuplicates()) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [NoMetadataTrackerMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testNetworkLoadedItemEntirePlayback() {
        let player = Player()
        let publisher = NoMetadataTrackerMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .properties, .disabled], from: publisher.removeDuplicates()) {
            player.append(.mock(
                url: Stream.shortOnDemand.url,
                loadedAfter: 1,
                trackerAdapters: [NoMetadataTrackerMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testFailedItem() {
        let player = Player()
        let publisher = NoMetadataTrackerMock.StatePublisher()
        expectEqualPublished(values: [.initialized, .enabled, .properties], from: publisher.removeDuplicates(), during: .milliseconds(500)) {
            player.append(.simple(
                url: Stream.unavailable.url,
                trackerAdapters: [NoMetadataTrackerMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testMetadata() {
        let player = Player()
        let publisher = TrackerMock<String>.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .properties, .updated("title"), .properties, .disabled], from: publisher.removeDuplicates()) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                metadata: AssetMetadataMock(title: "title"),
                trackerAdapters: [TrackerMock.adapter(statePublisher: publisher) { $0.title }]
            ))
            player.play()
        }
    }

    func testMetadataUpdate() {
        let player = Player()
        let publisher = TrackerMock<String>.StatePublisher()
        expectAtLeastEqualPublished(
            values: [.initialized, .enabled, .properties, .updated("title0"), .properties, .updated("title1"), .properties, .disabled],
            from: publisher.removeDuplicates()
        ) {
            player.append(.mock(url: Stream.shortOnDemand.url, withMetadataUpdateAfter: 1, trackerAdapters: [
                TrackerMock.adapter(statePublisher: publisher) { $0.title }
            ]))
            player.play()
        }
    }

    func testItemTransition() {
        let player = Player()
        let publisher = NoMetadataTrackerMock.StatePublisher()
        expectEqualPublished(values: [.initialized, .enabled, .properties, .disabled], from: publisher.removeDuplicates(), during: .seconds(5)) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [NoMetadataTrackerMock.adapter(statePublisher: publisher)]
            ))
            player.append(.simple(url: Stream.onDemand.url))
            player.play()
        }
    }
}
