//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class CommandersActStreamingAnalytics {
    var lastEvent: Event = .play

    init() {
        Analytics.shared.sendCommandersActStreamingEvent(name: Event.play.rawValue, labels: [:])
    }

    func notify(_ event: Event) {
        guard event != lastEvent else { return }

        switch (lastEvent, event) {
        case (.pause, .seek), (.pause, .eof):
            return
        default:
            Analytics.shared.sendCommandersActStreamingEvent(name: event.rawValue, labels: [:])
        }

        lastEvent = event
    }

    deinit {
        Analytics.shared.sendCommandersActStreamingEvent(name: "stop", labels: [:])
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
