//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import ComScore
import CoreMedia
import Player

final class ComScoreStreamingAnalytics: SCORStreamingAnalytics {
    private var oldRate: Float?

    override func notifyChangePlaybackRate(_ newRate: Float) {
        guard oldRate != newRate else { return }
        super.notifyChangePlaybackRate(newRate)
        oldRate = newRate
    }
}

extension ComScoreStreamingAnalytics {
    private static func duration(for properties: PlayerProperties) -> Int {
        properties.seekableTimeRange.isValid ? Int(properties.seekableTimeRange.duration.seconds.toMilliseconds) : 0
    }

    private static func position(for time: CMTime) -> Int {
        time.isValid ? Int(time.seconds.toMilliseconds) : 0
    }

    private static func offset(for properties: PlayerProperties, time: CMTime) -> Int {
        guard properties.seekableTimeRange.isValid, time.isValid else { return 0 }
        let offset = properties.seekableTimeRange.end - time
        return Int(offset.seconds.toMilliseconds)
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

    func setProperties(for properties: PlayerProperties, time: CMTime, streamType: StreamType) {
        if streamType == .dvr {
            start(fromDvrWindowOffset: Self.offset(for: properties, time: time))
            setDVRWindowLength(Self.duration(for: properties))
        }
        else {
            start(fromPosition: Self.position(for: time))
        }
    }
}
