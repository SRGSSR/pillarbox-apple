//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class CommandersActStreamingAnalytics {
    enum Event: String {
        case play
    }

    init() {
        Analytics.shared.sendCommandersActStreamingEvent(name: "play", labels: [:])
    }

    func notify(_ event: Event) {
        guard event != .play else { return }
        Analytics.shared.sendCommandersActStreamingEvent(name: event.rawValue, labels: [:])
    }

    deinit {
        Analytics.shared.sendCommandersActStreamingEvent(name: "stop", labels: [:])
    }
}
