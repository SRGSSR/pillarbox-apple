//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import UIKit

/// Metadata providing information about what is currently being played.
///
/// This metadata is most notably displayed in the Control Center.
public struct NowPlayingMetadata {
    /// The title.
    let title: String?

    /// The subtitle.
    let subtitle: String?

    /// The description.
    let description: String?

    /// The image suitable for artwork display.
    let image: UIImage?

    /// Creates now playing metadata.
    public init(title: String? = nil, subtitle: String? = nil, description: String? = nil, image: UIImage? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.image = image
    }
}

/// A type providing Control Center metadata.
public enum NowPlaying {
    /// Standard now playing metadata.
    public typealias Info = [String: Any]

    /// A list of properties for the now playing item.
    struct Properties {
        let timeRange: CMTimeRange
        let itemDuration: CMTime
        let isBuffering: Bool
    }
}
