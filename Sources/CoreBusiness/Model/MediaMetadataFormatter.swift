//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import UIKit

struct MediaMetadataFormatter: PlayerMetadataFormatter {
    func items(from metadata: MediaMetadata) -> [AVMetadataItem] {
        [
            .init(for: .commonIdentifierAssetIdentifier, value: metadata.identifier),
            .init(for: .commonIdentifierTitle, value: metadata.title),
            .init(for: .iTunesMetadataTrackSubTitle, value: metadata.subtitle),
            .init(for: .commonIdentifierArtwork, value: metadata.image?.pngData()),
            .init(for: .commonIdentifierDescription, value: metadata.description),
            .init(for: .quickTimeUserDataCreationDate, value: metadata.episodeDescription)
        ].compactMap { $0 }
    }

    func timedGroups(from metadata: MediaMetadata) -> [AVTimedMetadataGroup] {
        []
    }

    func chapterGroups(from metadata: MediaMetadata) -> [AVTimedMetadataGroup] {
        metadata.mediaComposition.chapters.map { chapter in
            AVTimedMetadataGroup(
                items: [
                    .init(for: .commonIdentifierAssetIdentifier, value: chapter.identifier),
                    .init(for: .commonIdentifierTitle, value: chapter.title),
                    .init(for: .commonIdentifierArtwork, value: metadata.image(for: chapter))
                ].compactMap { $0 },
                timeRange: chapter.timeRange
            )
        }
    }
}
