//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

final class CommandersActStreamingAnalytics {
    var lastEvent: Event = .play

    private var lastEventTime: CMTime = .zero
    private var lastEventDate = Date()

    init() {
        sendEvent(.play, at: .zero)
    }

    func notify(_ event: Event, at time: CMTime) {
        guard event != lastEvent else { return }

        switch (lastEvent, event) {
        case (.pause, .seek), (.pause, .eof):
            return
        case (.seek, .pause), (.seek, .eof):
            return
        case (.eof, _), (.stop, _):
            return
        default:
            sendEvent(event, at: time)
        }
    }

    private func sendEvent(_ event: Event, at time: CMTime) {
        lastEvent = event
        lastEventTime = time
        lastEventDate = Date()

        Analytics.shared.sendCommandersActStreamingEvent(name: event.rawValue, labels: [
            "media_player_display": "Pillarbox",
            "media_player_version": PackageInfo.version,
            "media_position": String(Int(time.seconds))
        ])
    }

    private func eventTime(after interval: CMTime) -> CMTime {
        return lastEvent == .play ? lastEventTime + interval : lastEventTime
    }

    deinit {
        let interval = CMTime(seconds: Date().timeIntervalSince(lastEventDate), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        sendEvent(.stop, at: eventTime(after: interval))
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
