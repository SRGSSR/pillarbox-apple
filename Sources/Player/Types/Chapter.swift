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

    /// The image associated with the content.
    public var image: UIImage? {
        switch imageSource {
        case let .image(image):
            return image
        default:
            return nil
        }
    }

    /// The time range covered by the chapter.
    public let timeRange: CMTimeRange

    private let imageSource: ImageSource

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
    ///   - imageSource: The source of the image associated with the content.
    ///   - timeRange: The time range covered by the chapter.
    ///
    /// The image should usually be reasonable in size (less than 1000px wide / tall is in general sufficient).
    public init(
        identifier: String? = nil,
        title: String? = nil,
        imageSource: ImageSource = .none,
        timeRange: CMTimeRange
    ) {
        self.identifier = identifier
        self.title = title
        self.imageSource = imageSource
        self.timeRange = timeRange
    }
}
