//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import ComScore
import CoreMedia
import PillarboxPlayer

final class ComScoreStreamingAnalytics: SCORStreamingAnalytics {
    private var oldRate: Float?

    override func notifyChangePlaybackRate(_ newRate: Float) {
        guard oldRate != newRate else { return }
        super.notifyChangePlaybackRate(newRate)
        oldRate = newRate
    }
}

extension ComScoreStreamingAnalytics {
    private static func duration(from properties: TrackerProperties) -> Int {
        properties.seekableTimeRange.duration.timeInterval().toMilliseconds
    }

    private static func position(from properties: TrackerProperties) -> Int {
        properties.time.timeInterval().toMilliseconds
    }

    private static func offset(from properties: TrackerProperties) -> Int {
        properties.endOffset().timeInterval().toMilliseconds
    }

    func notifyEvent(for playbackState: PlaybackState, at rate: Float) {
        switch playbackState {
        case .playing:
            notifyChangePlaybackRate(rate)
            notifyPlay()
        case .paused:
            notifyPause()
        case .ended:
            notifyEnd()
        default:
            break
        }
    }

    func setPlaybackPosition(from properties: TrackerProperties) {
        if properties.streamType == .dvr {
            start(fromDvrWindowOffset: Self.offset(from: properties))
            setDVRWindowLength(Self.duration(from: properties))
        }
        else {
            start(fromPosition: Self.position(from: properties))
        }
    }
}
