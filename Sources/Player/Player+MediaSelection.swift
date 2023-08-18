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
        mediaSelectionContext.characteristics
    }

    /// The list of media options associated with a characteristic.
    ///
    /// Use `mediaCharacteristics` to retrieve available characteristics.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The list of options associated with the characteristic of an empty array if none.
    func mediaSelectionOptions(for characteristic: AVMediaCharacteristic) -> [MediaSelectionOption] {
        guard let selector = mediaSelector(for: characteristic) else { return [] }
        return selector.mediaSelectionOptions()
    }

    /// The currently selected media option for a characteristic.
    ///
    /// Use `mediaCharacteristics` to retrieve available characteristics. Returns the selection based on
    /// MediaAccessibility.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The selected option or `nil` if none.
    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        guard let selection = mediaSelectionContext.selection, let selector = mediaSelector(for: characteristic) else {
            return .disabled
        }
        return selector.selectedMediaOption(in: selection)
    }

    /// Selects a media option for a characteristic.
    ///
    /// This method does nothing if the provided option is not associated with the characteristic. Use 
    /// `mediaCharacteristics` to retrieve available characteristics and sets the selection using MediaAccessibility.
    /// Ignores options not returned by `mediaSelectionOptions(for:)`.
    ///
    /// - Parameters:
    ///   - mediaOption: The option to select.
    ///   - characteristic: The characteristic.
    func select(mediaOption: MediaSelectionOption, for characteristic: AVMediaCharacteristic) {
        guard let item = queuePlayer.currentItem, let selector = mediaSelector(for: characteristic) else { return }
        selector.select(mediaOption: mediaOption, on: item)
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

    private func mediaSelector(for characteristic: AVMediaCharacteristic) -> MediaSelector? {
        guard let group = mediaSelectionContext.groups[characteristic] else { return nil }
        switch characteristic {
        case .audible:
            return AudibleMediaSelector(group: group)
        case .legible:
            return LegibleMediaSelector(group: group)
        default:
            return nil
        }
    }

    /// The currently active media option for a characteristic.
    ///
    /// This method can be used to retrieve the actual media selection option set by the player. This can be useful
    /// to retrieve options that can be automatically activated by the player, e.g. forced subtitles. Ignores
    /// MediaAccessibility and might therefore return forced subtitles.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The active option or `nil` if none.
    func activeMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        guard let option = mediaSelectionContext.selectedOption(for: characteristic) else { return .disabled }
        return .enabled(option)
    }
}
