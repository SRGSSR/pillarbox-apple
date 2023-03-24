//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import UIKit

public typealias NowPlayingInfo = [String: Any]

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

public protocol AssetMetadata {
    func nowPlayingMetadata() -> NowPlayingMetadata
}

public struct EmptyAssetMetadata: AssetMetadata {
    // Cannot be instantiated. Only meant to be used as a type in signatures and where clauses.
    private init() {}

    public func nowPlayingMetadata() -> NowPlayingMetadata {
        .init()
    }
}

enum NowPlaying {
    typealias Info = [String: Any]

    struct Properties {
        let timeRange: CMTimeRange
        let itemDuration: CMTime
        let isBuffering: Bool
    }
}
