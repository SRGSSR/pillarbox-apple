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

    func setPlaybackPosition(from properties: PlayerProperties) {
        if properties.streamType == .dvr {
            start(fromDvrWindowOffset: Self.offset(from: properties))
            setDVRWindowLength(Self.duration(from: properties))
        }
        else {
            start(fromPosition: Self.position(from: properties))
        }
    }
}

private extension ComScoreStreamingAnalytics {
    static func duration(from properties: PlayerProperties) -> Int {
        Int(properties.seekableTimeRange.duration.timeInterval().toMilliseconds)
    }

    static func position(from properties: PlayerProperties) -> Int {
        Int(properties.time().timeInterval().toMilliseconds)
    }

    static func offset(from properties: PlayerProperties) -> Int {
        Int(properties.endOffset().timeInterval().toMilliseconds)
    }
}
