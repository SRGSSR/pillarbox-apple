//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension Player {
    /// The set of media characteristics for which a media selection is available.
    var mediaSelectionCharacteristics: Set<AVMediaCharacteristic> {
        mediaSelections.characteristics
    }

    /// The list of media options associated with a characteristic.
    ///
    /// Use `mediaCharacteristics` to retrieve available characteristics.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The list of options associated with the characteristic of an empty array if none.
    func mediaSelectionOptions(for characteristic: AVMediaCharacteristic) -> [AVMediaSelectionOption] {
        mediaSelections.options(withMediaCharacteristic: characteristic)
    }

    /// The currently selected media option for a characteristic.
    ///
    /// Use `mediaCharacteristics` to retrieve available characteristics.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The selected option or `nil` if none.
    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> AVMediaSelectionOption? {
        nil
    }

    /// Selects a media option for a characteristic.
    ///
    /// This method does nothing if the provided option is not associated with the characteristic. Use `mediaCharacteristics`
    /// to retrieve available characteristics.
    ///
    /// - Parameters:
    ///   - mediaOption: The option to select.
    ///   - characteristic: The characteristic.
    func select(mediaOption: AVMediaSelectionOption?, for characteristic: AVMediaCharacteristic) {
    }

    /// Selects the media option that best matches the player automatic selection criteria for a characteristic.
    ///
    /// Use `mediaCharacteristics` to retrieve available characteristics.
    ///
    /// - Parameter characteristic: The characteristic
    func selectMediaOptionAutomatically(for characteristic: AVMediaCharacteristic) {
    }
}
