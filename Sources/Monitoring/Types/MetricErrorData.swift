//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MetricErrorData: Encodable {
    let audio: String?
    let message: String
    let name: String
    let position: Int?
    let positionTimestamp: Int?
    let subtitles: String?
    let url: URL?
    let vpn: Bool
}
