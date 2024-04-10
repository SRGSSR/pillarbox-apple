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
            .init(for: .commonIdentifierDescription, value: metadata.description)
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
                    .init(for: .commonIdentifierArtwork, value: UIImage.image(with: .systemPink).pngData())
                ].compactMap { $0 },
                timeRange: chapter.timeRange
            )
        }
    }
}

private extension UIImage {
    static func image(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { context in
            color.setFill()
            context.fill(rect)
        }
    }
}
