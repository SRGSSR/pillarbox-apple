//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MetricErrorData: Encodable {
    let severity: Severity
    let name: String
    let message: String
    let playerPosition: Int?
}
