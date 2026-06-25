//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import UIKit

/// A chapter representation.
public struct Chapter: Codable, Equatable {
    private static let placeholderImage = {
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

    private let startTimeMs: Int64
    private let endTimeMs: Int64

    /// The time range covered by the chapter.
    public var timeRange: CMTimeRange {
        .init(
            start: .init(value: CMTimeValue(startTimeMs), timescale: 1000),
            end: .init(value: CMTimeValue(endTimeMs), timescale: 1000)
        )
    }

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
        imageSource.fetchImage() ?? Self.placeholderImage
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
        self.startTimeMs = Int64(timeRange.start.seconds * 1000)
        self.endTimeMs = Int64(timeRange.end.seconds * 1000)
    }
}

extension Chapter {
    func lazyChapterPublisher() -> AnyPublisher<Chapter, Never> {
        imageSource.lazyImageSourcePublisher()
            .map(withImageSource)
            .eraseToAnyPublisher()
    }

    private func withImageSource(_ imageSource: ImageSource) -> Self {
        .init(identifier: identifier, title: title, imageSource: imageSource, timeRange: timeRange)
    }
}
