//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

struct AssetMetadataMock: Decodable {
    let title: String
    let subtitle: String?

    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}

extension AssetMetadataMock: AssetMetadata {
    static var title1: Self {
        .init(title: "title1")
    }

    static var title2: Self {
        .init(title: "title2")
    }

    var playerMetadata: PlayerMetadata {
        .init(title: title, subtitle: subtitle)
    }
}
