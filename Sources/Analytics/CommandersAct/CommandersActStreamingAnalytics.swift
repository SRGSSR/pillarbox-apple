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
    private var lastEventTime: CMTime = .zero
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

    private func sendEvent(_ event: Event, at time: CMTime, in range: CMTimeRange) {
        lastEvent = event
        lastEventTime = time
        lastEventDate = Date()

        Analytics.shared.sendCommandersActStreamingEvent(
            name: event.rawValue,
            labels: self.labels(at: time, in: range)
        )
    }

    private func labels(at time: CMTime, in range: CMTimeRange) -> [String: String] {
        var labels = [
            "media_player_display": "Pillarbox",
            "media_player_version": PackageInfo.version
        ]
        if isLive {
            labels["media_position"] = "0"
            labels["media_timeshift"] = String(Int((range.end - time).seconds))
        }
        else {
            labels["media_position"] = String(Int(time.seconds))
        }
        return labels
    }

    private func eventTime(after interval: CMTime) -> CMTime {
        lastEvent == .play ? lastEventTime + interval : lastEventTime
    }

    deinit {
        let interval = CMTime(seconds: Date().timeIntervalSince(lastEventDate), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        sendEvent(.stop, at: eventTime(after: interval), in: .zero)
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
