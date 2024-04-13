//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import UIKit

/// Metadata associated with a chapter.
public struct ChapterMetadata: Equatable {
    public let identifier: String?
    public let title: String?
    public let image: UIImage?
    public let timeRange: CMTimeRange

    var timedNavigationMarker: AVTimedMetadataGroup {
        .init(
            items: [
                .init(identifier: .commonIdentifierAssetIdentifier, value: identifier),
                .init(identifier: .commonIdentifierTitle, value: title),
                .init(identifier: .commonIdentifierArtwork, value: image?.pngData())
            ].compactMap { $0 },
            timeRange: timeRange
        )
    }

    public init(
        identifier: String? = nil,
        title: String? = nil,
        image: UIImage? = nil,
        timeRange: CMTimeRange
    ) {
        self.identifier = identifier
        self.title = title
        self.image = image
        self.timeRange = timeRange
    }
}
