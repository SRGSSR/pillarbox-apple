//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

final class MetricLog {
    @Published private(set) var events: [MetricEvent] = []

    func appendEvent(_ event: MetricEvent) {
        events += [event]
    }
}
