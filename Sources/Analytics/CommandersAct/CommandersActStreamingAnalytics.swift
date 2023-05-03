//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class CommandersActStreamingAnalytics {
    var lastEvent: Event = .play

    init() {
        sendEvent(.play)
    }

    func notify(_ event: Event) {
        guard event != lastEvent else { return }

        switch (lastEvent, event) {
        case (.pause, .seek), (.pause, .eof):
            return
        case (.seek, .pause), (.seek, .eof):
            return
        case (.eof, _), (.stop, _):
            return
        default:
            sendEvent(event)
        }

        lastEvent = event
    }

    private func sendEvent(_ event: Event) {
        Analytics.shared.sendCommandersActStreamingEvent(name: event.rawValue, labels: [
            "media_player_display": "Pillarbox",
            "media_player_version": PackageInfo.version
        ])
    }

    deinit {
        sendEvent(.stop)
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
