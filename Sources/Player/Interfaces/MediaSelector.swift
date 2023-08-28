//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A protocol for media selection logic.
protocol MediaSelector {
    /// The associated selection group.
    var group: AVMediaSelectionGroup { get }

    /// Creates the selector.
    init(group: AVMediaSelectionGroup)

    /// The available options.
    func mediaSelectionOptions() -> [MediaSelectionOption]

    /// The selected media option matching the provided selection.
    func selectedMediaOption(in selection: AVMediaSelection, of player: AVPlayer) -> MediaSelectionOption

    /// Selects the provided option, applying it on the specified item.
    func select(mediaOption: MediaSelectionOption, on item: AVPlayerItem, of player: AVPlayer)
}

extension MediaSelector {
    func supports(mediaSelectionOption: MediaSelectionOption) -> Bool {
        mediaSelectionOptions().contains(mediaSelectionOption)
    }
}
