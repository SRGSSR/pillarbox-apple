//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MetricErrorData: Encodable {
    let message: String
    let name: String
    let position: Int?
    let positionTimestamp: Int?
    let severity: Severity
    let url: URL?
    let vpn: Bool
}

extension MetricErrorData {
    enum Severity: String, Encodable {
        case fatal = "Fatal"
        case warning = "Warning"
    }
}
