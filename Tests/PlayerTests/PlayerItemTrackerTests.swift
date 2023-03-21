//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Foundation

final class PlayerItemTrackerTests: TestCase {
    func testEnableIsCalled() {
        let tracker = TrackerMock()
        _ = Player(item: .simple(url: Stream.shortOnDemand.url, trackers: [tracker]))
        expectAtLeastEqualPublished(values: [.enabled], from: tracker.$state)
    }
}
