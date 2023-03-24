//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import UIKit

/// Metadata used to display what is currently being played.
public struct NowPlayingMetadata {
    /// Title.
    let title: String?
    /// Subtitle.
    let subtitle: String?
    /// Description.
    let description: String?
    /// Image.
    let image: UIImage?

    /// Create an asset metadata.
    public init(title: String? = nil, subtitle: String? = nil, description: String? = nil, image: UIImage? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.image = image
    }
}
/// An enumeration representing the current media playback state.
public enum NowPlaying {
    /// A dictionary of metadata.
    public typealias Info = [String: Any]

    /// A struct representing properties of the currently playing media item.
    struct Properties {
        let timeRange: CMTimeRange
        let itemDuration: CMTime
        let isBuffering: Bool
    }
}
