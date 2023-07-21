//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import UIKit

struct YoutubeMetadata: AssetMetadata {
    let image: UIImage

    func nowPlayingMetadata() -> NowPlayingMetadata {
        .init(image: image)
    }
}
