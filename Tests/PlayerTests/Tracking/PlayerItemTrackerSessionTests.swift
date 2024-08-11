//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class PlayerItemTrackerSessionTests: TestCase {
    func testEmpty() {
        let player = Player()
        expect(player.currentSessionIdentifiers(trackedBy: PlayerItemTrackerMock.self)).to(beEmpty())
    }

    func testSessions() {
        let player = Player(
            item: .simple(
                url: Stream.onDemand.url,
                trackerAdapters: [
                    PlayerItemTrackerMock.adapter(configuration: .init(sessionIdentifier: "A")),
                    PlayerItemTrackerMock.adapter(configuration: .init()),
                    PlayerItemTrackerMock.adapter(configuration: .init(sessionIdentifier: "B"))
                ]
            )
        )
        expect(player.currentSessionIdentifiers(trackedBy: PlayerItemTrackerMock.self)).to(equal(["A", "B"]))
    }
}
