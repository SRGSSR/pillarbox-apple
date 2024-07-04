//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import PillarboxCircumspect
import PillarboxStreams

final class PlayerItemTrackerUpdateTests: TestCase {
    func testMetadata() {
        let player = Player()
        let publisher = TrackerUpdateMock<String>.StatePublisher()
        let item = PlayerItem.simple(
            url: Stream.shortOnDemand.url,
            metadata: AssetMetadataMock(title: "title"),
            trackerAdapters: [
                TrackerUpdateMock.adapter(statePublisher: publisher) { $0.title }
            ]
        )
        expectAtLeastEqualPublished(
            values: [
                .updatedMetadata("title"),
                .enabled,
                .updatedProperties,
                .disabled
            ],
            from: publisher.removeDuplicates()
        ) {
            player.append(item)
            player.play()
        }
    }

    func testMetadataUpdate() {
        let player = Player()
        let publisher = TrackerUpdateMock<String>.StatePublisher()
        let item = PlayerItem.mock(url: Stream.shortOnDemand.url, withMetadataUpdateAfter: 1, trackerAdapters: [
            TrackerUpdateMock.adapter(statePublisher: publisher) { $0.title }
        ])
        expectAtLeastEqualPublished(
            values: [
                .updatedMetadata("title0"),
                .enabled,
                .updatedProperties,
                .updatedMetadata("title1"),
                .updatedProperties,
                .disabled
            ],
            from: publisher.removeDuplicates()
        ) {
            player.append(item)
            player.play()
        }
    }
}
