//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble

class MetricsStateTests: TestCase {
    func testUpdateWithoutEvents() {
        let state = MetricsState.empty.updated(with: .init(
            events: [],
            after: .init(timeIntervalSince1970: 1)
        ))
        expect(state).to(beNil())
    }

    func testUpdateWithOpenEvent() {
        let initialState = MetricsState.empty.updated(with: .init(
            events: [
                .init(playbackStartDate: .init(timeIntervalSince1970: 1), numberOfStalls: 1),
                .init(playbackStartDate: .init(timeIntervalSince1970: 2), numberOfStalls: 2)
            ],
            after: nil
        ))!
        let state = initialState.updated(with: .init(
            events: [
                .init(playbackStartDate: .init(timeIntervalSince1970: 1), numberOfStalls: 1),
                .init(playbackStartDate: .init(timeIntervalSince1970: 2), numberOfStalls: 5)
            ],
            after: .init(timeIntervalSince1970: 1)
        ))!

        let metrics = state.metrics(from: initialState)!
        expect(metrics.increment.numberOfStalls).to(equal(3))
        expect(metrics.total.numberOfStalls).to(equal(6))
    }

    func testUpdateWithClosedAndOpenEvents() {
        let initialState = MetricsState.empty.updated(with: .init(
            events: [
                .init(playbackStartDate: .init(timeIntervalSince1970: 1), numberOfStalls: 1),
                .init(playbackStartDate: .init(timeIntervalSince1970: 2), numberOfStalls: 5)
            ],
            after: nil
        ))!
        let state = initialState.updated(with: .init(
            events: [
                .init(playbackStartDate: .init(timeIntervalSince1970: 1), numberOfStalls: 1),
                .init(playbackStartDate: .init(timeIntervalSince1970: 2), numberOfStalls: 8),
                .init(playbackStartDate: .init(timeIntervalSince1970: 3), numberOfStalls: 2)
            ],
            after: .init(timeIntervalSince1970: 1)
        ))!

        let metrics = state.metrics(from: initialState)!
        expect(metrics.increment.numberOfStalls).to(equal(5))
        expect(metrics.total.numberOfStalls).to(equal(11))
    }

    func testUpdateWithMultipleClosedAndInvalidEvents() {
        let initialState = MetricsState.empty.updated(with: .init(
            events: [
                .init(playbackStartDate: .init(timeIntervalSince1970: 1), numberOfStalls: 1),
                .init(playbackStartDate: .init(timeIntervalSince1970: 2), numberOfStalls: 5)
            ],
            after: nil
        ))!
        let state = initialState.updated(with: .init(
            events: [
                .init(playbackStartDate: .init(timeIntervalSince1970: 1), numberOfStalls: 1),
                .init(playbackStartDate: .init(timeIntervalSince1970: 2), numberOfStalls: 8),
                .init(playbackStartDate: .init(timeIntervalSince1970: 3), numberOfStalls: 2),
                .init(playbackStartDate: .init(timeIntervalSince1970: 4), numberOfStalls: 7)
            ],
            after: .init(timeIntervalSince1970: 1)
        ))!

        let metrics = state.metrics(from: initialState)!
        expect(metrics.increment.numberOfStalls).to(equal(12))
        expect(metrics.total.numberOfStalls).to(equal(18))
    }

    func testUpdateWithClosedAndInvalidEvents() {
        let initialState = MetricsState.empty.updated(with: .init(
            events: [
                .init(playbackStartDate: .init(timeIntervalSince1970: 1), numberOfStalls: 1),
                .init(playbackStartDate: .init(timeIntervalSince1970: 2), numberOfStalls: 2)
            ],
            after: nil
        ))!
        let state = initialState.updated(with: .init(
            events: [
                .init(playbackStartDate: .init(timeIntervalSince1970: 1), numberOfStalls: 1),
                .init(playbackStartDate: .init(timeIntervalSince1970: 2), numberOfStalls: 4),
                nil
            ],
            after: .init(timeIntervalSince1970: 1)
        ))!

        let metrics = state.metrics(from: initialState)!
        expect(metrics.increment.numberOfStalls).to(equal(2))
        expect(metrics.total.numberOfStalls).to(equal(5))
    }

    // swiftlint:disable:next function_body_length
    func testMetrics() {
        let initialState = MetricsState.empty
        let state = initialState.updated(with: .init(
            events: [
                .init(
                    playbackStartDate: Date(timeIntervalSince1970: 1),
                    uri: "uri",
                    serverAddress: "serverAddress",
                    playbackSessionId: "playbackSessionId",
                    playbackStartOffset: 2,
                    playbackType: "playbackType",
                    startupTime: 3,
                    observedBitrateStandardDeviation: 4,
                    indicatedBitrate: 5,
                    observedBitrate: 6,
                    averageAudioBitrate: 7,
                    averageVideoBitrate: 8,
                    indicatedAverageBitrate: 9,
                    numberOfServerAddressChanges: 10,
                    mediaRequestsWWAN: 11,
                    transferDuration: 12,
                    numberOfBytesTransferred: 13,
                    numberOfMediaRequests: 14,
                    durationWatched: 15,
                    numberOfDroppedVideoFrames: 16,
                    numberOfStalls: 17,
                    segmentsDownloadedDuration: 18,
                    downloadOverdue: 19,
                    switchBitrate: 20
                )
            ],
            after: nil
        ))!

        let metrics = state.metrics(from: initialState)!
        expect(metrics.playbackStartDate).to(equal(Date(timeIntervalSince1970: 1)))
        expect(metrics.uri).to(equal("uri"))
        expect(metrics.serverAddress).to(equal("serverAddress"))
        expect(metrics.playbackSessionId).to(equal("playbackSessionId"))
        expect(metrics.playbackStartOffset).to(equal(2))
        expect(metrics.playbackType).to(equal("playbackType"))
        expect(metrics.startupTime).to(equal(3))
        expect(metrics.observedBitrateStandardDeviation).to(equal(4))
        expect(metrics.indicatedBitrate).to(equal(5))
        expect(metrics.observedBitrate).to(equal(6))
        expect(metrics.averageAudioBitrate).to(equal(7))
        expect(metrics.averageVideoBitrate).to(equal(8))
        expect(metrics.indicatedAverageBitrate).to(equal(9))

        expect(metrics.increment.numberOfServerAddressChanges).to(equal(10))
        expect(metrics.increment.mediaRequestsWWAN).to(equal(11))
        expect(metrics.increment.transferDuration).to(equal(12))
        expect(metrics.increment.numberOfBytesTransferred).to(equal(13))
        expect(metrics.increment.numberOfMediaRequests).to(equal(14))
        expect(metrics.increment.durationWatched).to(equal(15))
        expect(metrics.increment.numberOfDroppedVideoFrames).to(equal(16))
        expect(metrics.increment.numberOfStalls).to(equal(17))
        expect(metrics.increment.segmentsDownloadedDuration).to(equal(18))
        expect(metrics.increment.downloadOverdue).to(equal(19))
        expect(metrics.increment.switchBitrate).to(equal(20))

        expect(metrics.total.numberOfServerAddressChanges).to(equal(10))
        expect(metrics.total.mediaRequestsWWAN).to(equal(11))
        expect(metrics.total.transferDuration).to(equal(12))
        expect(metrics.total.numberOfBytesTransferred).to(equal(13))
        expect(metrics.total.numberOfMediaRequests).to(equal(14))
        expect(metrics.total.durationWatched).to(equal(15))
        expect(metrics.total.numberOfDroppedVideoFrames).to(equal(16))
        expect(metrics.total.numberOfStalls).to(equal(17))
        expect(metrics.total.segmentsDownloadedDuration).to(equal(18))
        expect(metrics.total.downloadOverdue).to(equal(19))
        expect(metrics.total.switchBitrate).to(equal(20))
    }
}

private extension AccessLogEvent {
    init(playbackStartDate: Date = Date(), numberOfStalls: Int = -1) {
        self.init(
            playbackStartDate: playbackStartDate,
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
