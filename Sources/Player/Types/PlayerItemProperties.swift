//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct PlayerItemProperties: Equatable {
    static let empty = Self(
        itemProperties: .empty,
        mediaSelectionProperties: .empty,
        timeProperties: .empty,
        isEmpty: true
    )

    let itemProperties: ItemProperties
    let mediaSelectionProperties: MediaSelectionProperties
    let timeProperties: TimeProperties
    let isEmpty: Bool

    init(
        itemProperties: ItemProperties,
        mediaSelectionProperties: MediaSelectionProperties,
        timeProperties: TimeProperties
    ) {
        self.init(
            itemProperties: itemProperties,
            mediaSelectionProperties: mediaSelectionProperties,
            timeProperties: timeProperties,
            isEmpty: false
        )
    }

    private init(
        itemProperties: ItemProperties,
        mediaSelectionProperties: MediaSelectionProperties,
        timeProperties: TimeProperties,
        isEmpty: Bool
    ) {
        self.itemProperties = itemProperties
        self.mediaSelectionProperties = mediaSelectionProperties
        self.timeProperties = timeProperties
        self.isEmpty = isEmpty
    }
}
