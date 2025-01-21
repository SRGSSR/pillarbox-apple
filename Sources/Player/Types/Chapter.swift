//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import UIKit

/// A chapter representation.
public struct Chapter: Equatable {
    private static let placeholderImage: UIImage = {
        let rect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { context in
            UIColor.darkGray.setFill()
            context.fill(rect)
        }
    }()

    /// An identifier for the chapter.
    public let identifier: String?

    /// The chapter title.
    public let title: String?

    /// The source of the image associated with the content.
    public let imageSource: ImageSource

    /// The time range covered by the chapter.
    public let timeRange: CMTimeRange

    var timedNavigationMarker: AVTimedMetadataGroup {
        .init(
            items: [
                .init(identifier: .commonIdentifierAssetIdentifier, value: identifier),
                .init(identifier: .commonIdentifierTitle, value: title),
                .init(identifier: .commonIdentifierArtwork, value: artworkImage.pngData())
            ].compactMap(\.self),
            timeRange: timeRange
        )
    }

    private var artworkImage: UIImage {
        imageSource.image ?? Self.placeholderImage
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

extension Chapter {
    func chapterPublisher() -> AnyPublisher<Chapter, Never> {
        imageSource.imageSourcePublisher()
            .map { self.with(imageSource: $0) }
            .eraseToAnyPublisher()
    }

    private func with(imageSource: ImageSource) -> Self {
        .init(identifier: identifier, title: title, imageSource: imageSource, timeRange: timeRange)
    }
}
