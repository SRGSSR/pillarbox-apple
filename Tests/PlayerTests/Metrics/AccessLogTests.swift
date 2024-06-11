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
        let log = AccessLog(events: [])
        expect(log.previousEvents).to(beEmpty())
        expect(log.currentEvent).to(beNil())
    }

    func testSingleEvent() {
        let log = AccessLog(events: [.init(numberOfStalls: 1)])
        expect(log.previousEvents).to(beEmpty())
        expect(log.currentEvent?.numberOfStalls).to(equal(1))
    }

    func testMultipleEvents() {
        let log = AccessLog(events: [.init(numberOfStalls: 1), .init(numberOfStalls: 2)])
        expect(log.previousEvents.map(\.numberOfStalls)).to(equal([1]))
        expect(log.currentEvent?.numberOfStalls).to(equal(2))
    }

    func testMultipleInvalidEvents() {
        let log = AccessLog(events: [nil, nil])
        expect(log.previousEvents).to(beEmpty())
        expect(log.currentEvent).to(beNil())
    }

    func testValidAndInvalidEvents() {
        let log = AccessLog(events: [.init(numberOfStalls: 1), nil])
        expect(log.previousEvents.map(\.numberOfStalls)).to(equal([1]))
        expect(log.currentEvent).to(beNil())
    }

    func testInvalidAndValidEvents() {
        let log = AccessLog(events: [nil, .init(numberOfStalls: 2)])
        expect(log.previousEvents).to(beEmpty())
        expect(log.currentEvent?.numberOfStalls).to(equal(2))
    }
}

private extension AccessLogEvent {
    init(numberOfStalls: Int = -1) {
        self.init(
            playbackStartDate: Date(),
            uri: nil,
            serverAddress: nil,
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
            durationWatched: -1,
            numberOfDroppedVideoFrames: -1,
            numberOfStalls: numberOfStalls,
            segmentsDownloadedDuration: -1,
            downloadOverdue: -1,
            switchBitrate: -1
        )!
    }
}
