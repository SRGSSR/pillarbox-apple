//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MetricPayload<Data: Encodable>: Encodable {
    enum MetricName: String, Encodable {
        case start = "START"
        case error = "ERROR"
        case stop = "STOP"
    }

    let sessionId: UUID
    let eventName: MetricName
    let timestamp: TimeInterval
    let data: Data
}
