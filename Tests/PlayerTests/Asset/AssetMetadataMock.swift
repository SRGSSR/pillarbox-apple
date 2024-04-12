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

    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}

extension AssetMetadataMock: AssetMetadata {
    func items() -> [AVMetadataItem] {
        [
            .init(for: .commonIdentifierTitle, value: title),
            .init(for: .iTunesMetadataTrackSubTitle, value: subtitle)
        ].compactMap { $0 }
    }

    func timedGroups() -> [AVTimedMetadataGroup] {
        []
    }

    func chapterGroups() -> [AVTimedMetadataGroup] {
        []
    }
}
