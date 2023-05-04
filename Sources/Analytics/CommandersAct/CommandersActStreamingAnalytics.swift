//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

final class CommandersActStreamingAnalytics {
    var lastEvent: Event = .play

    private var isLive: Bool
    private var isBuffering = false
    private var playbackDuration: TimeInterval = 0
    private var lastEventTime: CMTime = .zero
    private var lastEventRange: CMTimeRange = .zero
    private var lastEventDate = Date()

    init(at time: CMTime, in range: CMTimeRange, isLive: Bool) {
        self.isLive = isLive
        sendEvent(.play, at: time, in: range)
    }

    func notify(_ event: Event, at time: CMTime, in range: CMTimeRange) {
        guard event != lastEvent else { return }

        switch (lastEvent, event) {
        case (.pause, .seek), (.pause, .eof):
            return
        case (.seek, .pause), (.seek, .eof):
            return
        case (.eof, _), (.stop, _):
            return
        default:
            sendEvent(event, at: time, in: range)
        }
    }

    func notify(isBuffering: Bool, time: CMTime, range: CMTimeRange) {
        updateReferences(at: time, in: range)
        self.isBuffering = isBuffering
    }

    private func sendEvent(_ event: Event, at time: CMTime, in range: CMTimeRange) {
        updateReferences(at: time, in: range)
        lastEvent = event

        Analytics.shared.sendCommandersActStreamingEvent(
            name: event.rawValue,
            labels: self.labels(at: time, in: range, playbackDuration: playbackDuration)
        )
    }

    private func labels(at time: CMTime, in range: CMTimeRange, playbackDuration: TimeInterval) -> [String: String] {
        var labels = [
            "media_player_display": "Pillarbox",
            "media_player_version": PackageInfo.version
        ]
        if isLive {
            labels["media_position"] = String(Int(playbackDuration))
            labels["media_timeshift"] = String(Int((range.end - time).timeInterval()))
        }
        else {
            labels["media_position"] = String(Int(time.timeInterval()))
        }
        return labels
    }

    private func updateReferences(at time: CMTime, in range: CMTimeRange) {
        if lastEvent == .play, !isBuffering {
            playbackDuration += Date().timeIntervalSince(lastEventDate)
        }

        lastEventTime = time
        lastEventRange = range
        lastEventDate = Date()
    }

    private func eventTime(after interval: CMTime) -> CMTime {
        lastEvent == .play && !isBuffering ? lastEventTime + interval : lastEventTime
    }

    private func eventRange(after interval: CMTime) -> CMTimeRange {
        .init(start: lastEventRange.start + interval, duration: lastEventRange.duration)
    }

    deinit {
        let interval = CMTime(seconds: Date().timeIntervalSince(lastEventDate), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        notify(.stop, at: eventTime(after: interval), in: eventRange(after: interval))
    }
}

extension CommandersActStreamingAnalytics {
    enum Event: String {
        case play
        case pause
        case seek
        case eof
        case stop
    }
}
