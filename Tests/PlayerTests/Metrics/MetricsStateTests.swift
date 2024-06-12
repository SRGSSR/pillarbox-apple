//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble

class MetricsStateTests: TestCase {
    func testSimpleUpdate() {
        let state = MetricsState(log: .init(
            events: [
                .init(playbackStartDate: .init(timeIntervalSince1970: 1), numberOfStalls: 2),
                .init(playbackStartDate: .init(timeIntervalSince1970: 2), numberOfStalls: 1),
            ],
            after: nil
        ))
        let newState = state.update(with: .init(
            events: [
                .init(playbackStartDate: .init(timeIntervalSince1970: 3), numberOfStalls: 2),
                .init(playbackStartDate: .init(timeIntervalSince1970: 4), numberOfStalls: 2),
                .init(playbackStartDate: .init(timeIntervalSince1970: 5), numberOfStalls: 2),
            ],
            after: nil
        ))

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

