//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MetricPayload<Data>: Encodable where Data: Encodable {
    let version = 1
    let sessionId: String
    let eventName: EventName
    let timestamp = Date.now.timestamp
    let data: Data
}
