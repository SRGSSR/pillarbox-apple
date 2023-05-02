//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class CommandersActStreamingAnalytics {
    init() {
        Analytics.shared.sendCommandersActStreamingEvent(name: "play", labels: [:])
    }

    deinit {
        Analytics.shared.sendCommandersActStreamingEvent(name: "stop", labels: [:])
    }
}
