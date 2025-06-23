//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import ComScore
import CoreMedia
import PillarboxPlayer

extension SCORStreamingAnalytics {
    private static func duration(from properties: TrackerProperties) -> Int {
        properties.seekableTimeRange.duration.timeInterval().toMilliseconds
    }

    private static func position(from properties: TrackerProperties) -> Int {
        properties.time.timeInterval().toMilliseconds
    }

    private static func offset(from properties: TrackerProperties) -> Int {
        properties.endOffset().timeInterval().toMilliseconds
    }

    func notifyEvent(with properties: TrackerProperties, rate: inout Float) {
        switch properties.playbackState {
        case .playing:
            notifyChangePlaybackRate(to: properties.rate, from: &rate)
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

    private func notifyChangePlaybackRate(to rate: Float, from previousRate: inout Float) {
        guard previousRate != rate else { return }
        notifyChangePlaybackRate(rate)
        previousRate = rate
    }
}
