//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer

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

extension AssetMetadataMock: PlayerItemMetadata {
    func items() -> [AVMetadataItem] {
        []
    }
    
    func timedGroups() -> [AVTimedMetadataGroup] {
        []
    }
    
    func chapterGroups() -> [AVTimedMetadataGroup] {
        []
    }
}
