//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaPlayer

/// Metadata associated with playback.
public struct PlayerMetadata: Equatable {
    static let empty = Self()

    /// An identifier for the content.
    public let identifier: String?

    /// The content title.
    public let title: String?

    /// A subtitle for the content.
    public let subtitle: String?

    /// A description of the content.
    public let description: String?

    /// The image associated with the content.
    public let image: UIImage?

    /// Episode information associated with the content.
    public let episode: String?

    /// Chapter associated with the content.
    public let chapters: [ChapterMetadata]

    var externalMetadata: [AVMetadataItem] {
        [
            .init(identifier: .commonIdentifierAssetIdentifier, value: identifier),
            .init(identifier: .commonIdentifierTitle, value: title),
            .init(identifier: .iTunesMetadataTrackSubTitle, value: subtitle),
            .init(identifier: .commonIdentifierArtwork, value: image?.pngData()),
            .init(identifier: .commonIdentifierDescription, value: description),
            .init(identifier: .quickTimeUserDataCreationDate, value: episode)
        ].compactMap { $0 }
    }

    var nowPlayingInfo: NowPlayingInfo {
        var nowPlayingInfo = NowPlayingInfo()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = subtitle
        if let image {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        return nowPlayingInfo
    }

    var timedNavigationMarkers: [AVTimedMetadataGroup] {
        chapters.map(\.timedNavigationMarker)
    }

    /// Creates metadata.
    ///
    /// - Parameters:
    ///   - identifier: An identifier for the content.
    ///   - title: The content title.
    ///   - subtitle: A subtitle for the content.
    ///   - description: A description of the content.
    ///   - image: The image associated with the content.
    ///   - episode: Episode information associated with the content.
    ///   - chapters: Chapter associated with the content.
    public init(
        identifier: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        image: UIImage? = nil,
        episode: String? = nil,
        chapters: [ChapterMetadata] = []
    ) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.image = image
        self.episode = episode
        self.chapters = chapters
    }
}
