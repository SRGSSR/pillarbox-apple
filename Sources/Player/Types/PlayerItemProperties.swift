//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct PlayerItemProperties: Equatable {
    static var empty: Self {
        .init(
            itemProperties: .empty,
            mediaSelectionProperties: .empty,
            timeProperties: .empty
        )
    }

    static var buffering: Self {
        .init(
            itemProperties: .empty,
            mediaSelectionProperties: .empty,
            timeProperties: .buffering
        )
    }

    let itemProperties: ItemProperties
    let mediaSelectionProperties: MediaSelectionProperties
    let timeProperties: TimeProperties
}
