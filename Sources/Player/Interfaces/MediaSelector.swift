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

    /// The selected persisted media option matching the provided selection.
    func persistedSelectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption

    /// Selects the provided option, applying it on the specified item.
    func select(mediaOption: MediaSelectionOption, on item: AVPlayerItem, in player: AVPlayer)
}

extension MediaSelector {
    func supports(mediaSelectionOption: MediaSelectionOption) -> Bool {
        mediaSelectionOptions().contains(mediaSelectionOption)
    }

    func selectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption {
        if let option = selection.selectedMediaOption(in: group) {
            return .on(option)
        }
        else {
            return .off
        }
    }

    func persistedSelectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption {
        selectedMediaOption(in: selection)
    }
}
