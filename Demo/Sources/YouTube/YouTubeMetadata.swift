//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import UIKit

struct YouTubeMetadata: AssetMetadata {
    let videoId: String
    let url: URL
    let image: UIImage

    func nowPlayingMetadata() -> NowPlayingMetadata {
        .init(title: "YouTube (\(videoId))", subtitle: url.absoluteString, image: image)
    }
}
