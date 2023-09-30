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

    let itemProperties: ItemProperties
    let mediaSelectionProperties: MediaSelectionProperties
    let timeProperties: TimeProperties
}
