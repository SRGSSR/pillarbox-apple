//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player

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

extension AssetMetadataMock: AssetMetadata {
    func nowPlayingMetadata() -> NowPlayingMetadata {
        .init(title: title, subtitle: subtitle, description: description)
    }
}
