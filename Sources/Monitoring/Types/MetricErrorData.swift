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
    let url: URL?
    let vpn: Bool
}
