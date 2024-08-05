//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MetricErrorData: Encodable {
    enum Severity: String, Encodable {
        case warning = "WARNING"
        case fatal = "FATAL"
    }

    let severity: Severity
    let name: String
    let message: String
    let playerPosition: Int?
}
