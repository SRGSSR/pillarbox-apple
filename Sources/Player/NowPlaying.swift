//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import UIKit

/// Metadata used to display what is currently being played, most notably in the Control Center.
public struct NowPlayingMetadata {
    /// Title.
    let title: String?

    /// Subtitle.
    let subtitle: String?

    /// Description.
    let description: String?

    /// Image.
    let image: UIImage?

    /// Create a now playing metadata.
    public init(title: String? = nil, subtitle: String? = nil, description: String? = nil, image: UIImage? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.image = image
    }
}

/// Types related to current metadata display in the control center.
public enum NowPlaying {
    /// Now playing information.
    public typealias Info = [String: Any]

    /// Playback properties for the now playing item.
    struct Properties {
        let timeRange: CMTimeRange
        let itemDuration: CMTime
        let isBuffering: Bool
    }
}
