//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct Resource: Decodable {
    enum CodingKeys: String, CodingKey {
        case url
        case streamingMethod = "streaming"
    }

    let url: URL
    let streamingMethod: StreamingMethod
}
