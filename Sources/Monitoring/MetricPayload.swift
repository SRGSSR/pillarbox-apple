//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MetricPayload<Data: Encodable>: Encodable {
    let sessionId: String
    let eventName: MetricName
    let timestamp: String
    let data: Data
}
