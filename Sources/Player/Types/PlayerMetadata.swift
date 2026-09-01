//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import CoreMedia
import MediaPlayer

public typealias PlayerMetadata = AssetMetadata<EmptyCustomData>

public extension AssetMetadata where CustomData == EmptyCustomData {
    /// Empty metadata.
    static let empty = Self(customData: .init())

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
