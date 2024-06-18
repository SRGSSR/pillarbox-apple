//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble

final class AccessLogEventTests: TestCase {
    func testNegativeValues() {
        let event = AccessLogEvent(
            uri: nil,
            serverAddress: nil,
            playbackStartDate: Date(),
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
            numberOfStalls: -1,
            segmentsDownloadedDuration: -1,
            downloadOverdue: -1,
            switchBitrate: -1
        )
        expect(event.playbackStartOffset).to(beNil())
        expect(event.startupTime).to(beNil())
        expect(event.observedBitrateStandardDeviation).to(beNil())
        expect(event.indicatedBitrate).to(beNil())
        expect(event.observedBitrate).to(beNil())
        expect(event.averageAudioBitrate).to(beNil())
        expect(event.averageVideoBitrate).to(beNil())
        expect(event.indicatedAverageBitrate).to(beNil())
        expect(event.numberOfServerAddressChanges).to(equal(0))
        expect(event.mediaRequestsWWAN).to(equal(0))
        expect(event.transferDuration).to(equal(0))
        expect(event.numberOfBytesTransferred).to(equal(0))
        expect(event.numberOfMediaRequests).to(equal(0))
        expect(event.playbackDuration).to(equal(0))
        expect(event.numberOfDroppedVideoFrames).to(equal(0))
        expect(event.numberOfStalls).to(equal(0))
        expect(event.segmentsDownloadedDuration).to(equal(0))
        expect(event.downloadOverdue).to(equal(0))
        expect(event.switchBitrate).to(equal(0))
    }

    func testMissingPlaybackStartDate() {
        let event = AccessLogEvent(
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
            numberOfStalls: -1,
            segmentsDownloadedDuration: -1,
            downloadOverdue: -1,
            switchBitrate: -1
        )
        expect(event).to(beNil())
    }
}
