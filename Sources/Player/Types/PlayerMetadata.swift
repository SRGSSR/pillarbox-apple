//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import CoreMedia
import MediaPlayer

/// Metadata associated with playback.
public typealias PlayerMetadata = AssetMetadata<EmptyCustomData>

public extension PlayerMetadata {
    /// Empty metadata.
    static let empty = Self()

    /// Creates metadata.
    ///
    /// - Parameters:
    ///   - identifier: An identifier for the content.
    ///   - title: The content title.
    ///   - subtitle: A subtitle for the content.
    ///   - description: A description of the content.
    ///   - imageSource: The source of the image associated with the content.
    ///   - viewport: The content viewport.
    ///   - episodeInformation: Episode information associated with the content.
    ///   - chapters: Chapter associated with the content.
    ///   - timeRanges: Time ranges associated with the content.
    ///
    /// The image should usually be reasonable in size (less than 1000px wide / tall is in general sufficient).
    init(
        identifier: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        imageSource: ImageSource = .none,
        viewport: Viewport = .standard,
        episodeInformation: EpisodeInformation? = nil,
        chapters: [Chapter] = [],
        timeRanges: [TimeRange] = []
    ) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.imageSource = imageSource
        self.viewport = viewport
        self.episodeInformation = episodeInformation
        self.chapters = chapters
        self.timeRanges = timeRanges
        self.customData = .init()
    }
}
