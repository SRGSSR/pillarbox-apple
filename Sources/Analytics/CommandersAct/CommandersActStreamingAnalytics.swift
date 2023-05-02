//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class CommandersActStreamingAnalytics {
    private var lastEvent: Event?

    init() {
        Analytics.shared.sendCommandersActStreamingEvent(name: "play", labels: [:])
    }

    func notify(_ event: Event) {
        guard event != .play, event != lastEvent else { return }
        Analytics.shared.sendCommandersActStreamingEvent(name: event.rawValue, labels: [:])
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
