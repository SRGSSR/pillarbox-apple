//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A protocol for media selection logic.
protocol MediaSelector {
    /// Creates the selector.
    init(group: AVMediaSelectionGroup)

    /// The available options.
    func mediaSelectionOptions() -> [MediaSelectionOption]

    /// The selected media option matching the provided selection.
    ///
    /// - Parameters:
    ///   - selection: The current selection information.
    ///   - selectionCriteria: The current selection criteria.
    /// - Returns: The selected media option.
    ///
    /// Use available information to refine the choice of the selected media option to return.
    func selectedMediaOption(in selection: AVMediaSelection?, with selectionCriteria: AVPlayerMediaSelectionCriteria?) -> MediaSelectionOption

    /// Selects the provided option, applying it on the specified item.
    ///
    /// - Parameters:
    ///   - mediaOption: The media option to select.
    ///   - item: The item on which the option must be selected.
    ///   - selectionCriteria: The current selection criteria.
    /// - Returns: Updated media selection to apply on return. Return `nil` if no update is required.
    ///
    /// If selection should alter media selection criteria your implementation should update the received value
    /// and return the corresponding result.
    func select(
        mediaOption: MediaSelectionOption,
        on item: AVPlayerItem,
        with selectionCriteria: AVPlayerMediaSelectionCriteria?
    ) -> AVPlayerMediaSelectionCriteria?
}

extension MediaSelector {
    func supports(mediaSelectionOption: MediaSelectionOption) -> Bool {
        mediaSelectionOptions().contains(mediaSelectionOption)
    }
}
