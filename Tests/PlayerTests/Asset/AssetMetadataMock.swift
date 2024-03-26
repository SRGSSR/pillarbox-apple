//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct AssetMetadataMock: Decodable {
    let title: String
    let subtitle: String?
    let description: String?

    init(title: String, subtitle: String? = nil, description: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
    }
}
