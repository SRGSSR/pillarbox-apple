//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import UIKit

/// A chapter representation.
public struct Chapter: Equatable {
    /// An identifier for the chapter.
    public let identifier: String?

    /// The chapter title.
    public let title: String?

    /// The time range covered by the chapter.
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

    /// Creates a chapter.
    ///
    /// - Parameters:
    ///   - identifier: An identifier for the chapter.
    ///   - title: The chapter title.
    ///   - image: The image associated with the chapter.
    ///   - timeRange: The time range covered by the chapter.
    public init(
        identifier: String? = nil,
        title: String? = nil,
        timeRange: CMTimeRange
    ) {
        self.identifier = identifier
        self.title = title
        self.timeRange = timeRange
    }
}

extension Chapter {
    /// The image associated with the chapter.
    ///
    /// The image should usually be reasonable in size (less than 1000px wide / tall is in general sufficient).
    public var image: UIImage? {
        nil
    }
}
