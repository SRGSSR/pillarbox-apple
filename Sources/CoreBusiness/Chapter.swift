//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct Chapter: Decodable {
    enum CodingKeys: String, CodingKey {
        case urn
        case title
        case resources = "resourceList"
    }

    let urn: String
    let title: String
    let resources: [Resource]
}

extension Chapter {
    var recommendedResource: Resource {
        resources.first!
    }
}
