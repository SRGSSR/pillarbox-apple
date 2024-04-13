//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia
import MediaPlayer
import PillarboxCore

public struct ChapterMetadata: Equatable {
    public let identifier: String?
    public let title: String?
    public let image: UIImage?
    public let timeRange: CMTimeRange

    fileprivate var timedNavigationMarker: AVTimedMetadataGroup {
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

public struct PlayerMetadata: Equatable {
    public static let empty = Self()

    public let identifier: String?
    public let title: String?
    public let subtitle: String?
    public let description: String?
    public let image: UIImage?
    public let episode: String?

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
