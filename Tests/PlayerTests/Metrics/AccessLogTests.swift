//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble

class AccessLogTests: TestCase {
    func testNoEvent() {
        let log = AccessLog(events: [], after: nil)
        expect(log.closedEvents).to(beEmpty())
        expect(log.openEvent).to(beNil())
    }

    func testSingleEvent() {
        let log = AccessLog(events: [.init(numberOfStalls: 1)], after: nil)
        expect(log.closedEvents).to(beEmpty())
        expect(log.openEvent?.numberOfStalls).to(equal(1))
    }

    func testMultipleEvents() {
        let log = AccessLog(events: [.init(numberOfStalls: 1), .init(numberOfStalls: 2)], after: nil)
        expect(log.closedEvents.map(\.numberOfStalls)).to(equal([1]))
        expect(log.openEvent?.numberOfStalls).to(equal(2))
    }

    func testMultipleInvalidEvents() {
        let log = AccessLog(events: [nil, nil], after: nil)
        expect(log.closedEvents).to(beEmpty())
        expect(log.openEvent).to(beNil())
    }

    func testValidAndInvalidEvents() {
        let log = AccessLog(events: [.init(numberOfStalls: 1), nil], after: nil)
        expect(log.closedEvents.map(\.numberOfStalls)).to(equal([1]))
        expect(log.openEvent).to(beNil())
    }

    func testInvalidAndValidEvents() {
        let log = AccessLog(events: [nil, .init(numberOfStalls: 2)], after: nil)
        expect(log.closedEvents).to(beEmpty())
        expect(log.openEvent?.numberOfStalls).to(equal(2))
    }

    func testDateBefore() {
        let log = AccessLog(
            events: [
                .init(playbackStartDate: Date(timeIntervalSince1970: 1), numberOfStalls: 1),
                .init(playbackStartDate: Date(timeIntervalSince1970: 2), numberOfStalls: 2),
                .init(playbackStartDate: Date(timeIntervalSince1970: 3), numberOfStalls: 3)
            ],
            after: Date(timeIntervalSince1970: 1)
        )

        expect(log.closedEvents.map(\.numberOfStalls)).to(equal([2]))
        expect(log.openEvent?.numberOfStalls).to(equal(3))
    }

    func testDateInside() {
        let log = AccessLog(
            events: [
                .init(playbackStartDate: Date(timeIntervalSince1970: 1), numberOfStalls: 1),
                .init(playbackStartDate: Date(timeIntervalSince1970: 2), numberOfStalls: 2),
                .init(playbackStartDate: Date(timeIntervalSince1970: 3), numberOfStalls: 3)
            ],
            after: Date(timeIntervalSince1970: 2)
        )

        expect(log.closedEvents).to(beEmpty())
        expect(log.openEvent?.numberOfStalls).to(equal(3))
    }

    func testDateAfter() {
        let log = AccessLog(
            events: [
                .init(playbackStartDate: Date(timeIntervalSince1970: 1), numberOfStalls: 1),
                .init(playbackStartDate: Date(timeIntervalSince1970: 2), numberOfStalls: 2),
                .init(playbackStartDate: Date(timeIntervalSince1970: 3), numberOfStalls: 3)
            ],
            after: Date(timeIntervalSince1970: 3)
        )

        expect(log.closedEvents).to(beEmpty())
        expect(log.openEvent).to(beNil())
    }
}

private extension AccessLogEvent {
    init(playbackStartDate: Date? = nil, numberOfStalls: Int = -1) {
        self.init(
            uri: nil,
            serverAddress: nil,
            playbackStartDate: playbackStartDate,
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
