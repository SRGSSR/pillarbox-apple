//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

public extension Player {
    /// The set of media characteristics for which a media selection is available.
    var mediaSelectionCharacteristics: Set<AVMediaCharacteristic> {
        mediaSelector.characteristics
    }

    /// The list of media options associated with a characteristic.
    ///
    /// Use `mediaCharacteristics` to retrieve available characteristics.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The list of options associated with the characteristic of an empty array if none.
    func mediaSelectionOptions(for characteristic: AVMediaCharacteristic) -> [MediaSelectionOption] {
        mediaSelector.options(for: characteristic)
    }

    /// The currently selected media option for a characteristic.
    ///
    /// Use `mediaCharacteristics` to retrieve available characteristics.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The selected option or `nil` if none.
    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        mediaSelector.selectedMediaOption(for: characteristic)
    }

    /// Selects a media option for a characteristic.
    ///
    /// This method does nothing if the provided option is not associated with the characteristic. Use `mediaCharacteristics`
    /// to retrieve available characteristics.
    ///
    /// - Parameters:
    ///   - mediaOption: The option to select.
    ///   - characteristic: The characteristic.
    func select(mediaOption: MediaSelectionOption, for characteristic: AVMediaCharacteristic) {
        mediaSelector.select(mediaOption: mediaOption, for: characteristic, in: queuePlayer.currentItem)
    }

    /// A binding to read and write the current media selection for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The binding.
    func mediaOption(for characteristic: AVMediaCharacteristic) -> Binding<MediaSelectionOption> {
        .init {
            self.selectedMediaOption(for: characteristic)
        } set: { newValue in
            self.select(mediaOption: newValue, for: characteristic)
        }
    }
}
