//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer

struct MediaFormatter: PlayerMetadataFormatter {
    func items(from metadata: Media) -> [AVMetadataItem] {
        [
            .init(for: .commonIdentifierTitle, value: metadata.title),
            .init(for: .iTunesMetadataTrackSubTitle, value: metadata.subtitle),
            .init(for: .commonIdentifierArtwork, value: metadata.image?.pngData())
        ].compactMap { $0 }
    }

    func timedGroups(from metadata: Media) -> [AVTimedMetadataGroup] {
        []
    }

    func chapterGroups(from metadata: Media) -> [AVTimedMetadataGroup] {
        []
    }
}
