//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

public extension MetadataAdapter where M == MediaMetadata {
    /// A metadata adapter displaying standard media metadata.
    static let standard: Self = StandardMetadata.adapter { metadata in
        .init(
            title: metadata.title,
            subtitle: metadata.subtitle,
            description: metadata.description,
            image: metadata.image,
            chapters: metadata.mediaComposition.chapters.map { chapter in
                StandardMetadata.Chapter(
                    title: chapter.title,
                    range: chapter.timeRange,
                    image: UIImage.image(with: .systemPink)
                )
            }
        )
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
