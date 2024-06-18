//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble

class AccessLogTests: TestCase {
    func testWithoutEvent() {
        let log = AccessLog(events: [], after: 0)
        expect(log.closedEvents).to(beEmpty())
        expect(log.openEvent).to(beNil())
    }

    func testWithSingleEvent() {
        let log = AccessLog(events: [.init(numberOfStalls: 1)], after: 0)
        expect(log.closedEvents).to(beEmpty())
        expect(log.openEvent?.numberOfStalls).to(equal(1))
    }

    func testWithMultipleEventsAfterValidIndex() {
        let log = AccessLog(
            events: [
                .init(numberOfStalls: 1),
                .init(numberOfStalls: 2),
                .init(numberOfStalls: 3)
            ],
            after: 1
        )

        expect(log.closedEvents.map(\.numberOfStalls)).to(equal([2]))
        expect(log.openEvent?.numberOfStalls).to(equal(3))
    }

    func testWithMultipleEventsAfterInvalidIndex() {
        let log = AccessLog(
            events: [
                .init(numberOfStalls: 1),
                .init(numberOfStalls: 2),
                .init(numberOfStalls: 3)
            ],
            after: 42
        )

        expect(log.closedEvents).to(beEmpty())
        expect(log.openEvent).to(beNil())
    }
}

private extension AccessLogEvent {
    init(numberOfStalls: Int = -1) {
        self.init(
            uri: nil,
            serverAddress: nil,
            playbackStartDate: nil,
            playbackSessionId: nil,
            playbackStartOffset: -1,
            playbackType: nil,
            startupTime: -1,
            observedBitrateStandardDeviation: -1,
            indicatedBitrate: -1,
            observedBitrate: -1,
            averageAudioBitrate: -1,
            averageVideoBitrate: -1,
            indicatedAverageBitrate: -1,
            numberOfServerAddressChanges: -1,
            mediaRequestsWWAN: -1,
            transferDuration: -1,
            numberOfBytesTransferred: -1,
            numberOfMediaRequests: -1,
            playbackDuration: -1,
            numberOfDroppedVideoFrames: -1,
            numberOfStalls: numberOfStalls,
            segmentsDownloadedDuration: -1,
            downloadOverdue: -1,
            switchBitrate: -1
        )
    }
}
