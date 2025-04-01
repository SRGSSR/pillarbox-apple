//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

struct PlaylistEntry: Hashable {
    let media: Media
    let item: PlayerItem

    init(media: Media) {
        self.media = media
        self.item = media.item()
    }
}
