//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MetricPayload<Data: Encodable>: Encodable {
    let version = "1.0.0"
    let sessionId: String
    let eventName: EventName
    let timestamp: TimeInterval
    let data: Data
}
