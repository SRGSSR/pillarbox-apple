//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility
import SwiftUI

public extension Player {
    /// The set of media characteristics for which a media selection is available.
    var mediaSelectionCharacteristics: Set<AVMediaCharacteristic> {
        mediaSelectionContext.characteristics
    }

    private static func preferredLanguages(for characteristic: AVMediaCharacteristic) -> [String] {
        switch characteristic {
        case .legible:
            MACaptionAppearanceCopySelectedLanguages(.user).takeUnretainedValue() as? [String] ?? []
        default:
            []
        }
    }

    /// The list of media options associated with a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The list of options associated with the characteristic.
    ///
    /// Use `mediaCharacteristics` to retrieve available characteristics.
    func mediaSelectionOptions(for characteristic: AVMediaCharacteristic) -> [MediaSelectionOption] {
        guard let selector = mediaSelector(for: characteristic) else { return [] }
        return selector.mediaSelectionOptions()
    }

    /// The currently selected media option for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The selected option.
    ///
    /// Returns the selection based on [Media Accessibility](https://developer.apple.com/documentation/mediaaccessibility).
    /// This ensures that selection made in other apps relying on Media Accessibility is automatically restored.
    ///
    /// You can use `mediaCharacteristics` to retrieve available characteristics.
    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        guard let selection = mediaSelectionContext.selection, let selector = mediaSelector(for: characteristic) else {
            return .off
        }

        let option = selectedMediaOption(in: selection, with: selector, for: characteristic)
        return selector.supports(mediaSelectionOption: option) ? option : .off
    }

    private func selectedMediaOption(
        in selection: AVMediaSelection,
        with selector: MediaSelector,
        for characteristic: AVMediaCharacteristic
    ) -> MediaSelectionOption {
        if queuePlayer.mediaSelectionCriteria(forMediaCharacteristic: characteristic) == nil {
            return selector.persistedSelectedMediaOption(in: selection)
        }
        else {
            return selector.selectedMediaOption(in: selection)
        }
    }

    /// Selects a media option for a characteristic.
    ///
    /// - Parameters:
    ///   - mediaOption: The option to select.
    ///   - characteristic: The characteristic.
    ///
    /// Sets the selection using [Media Accessibility](https://developer.apple.com/documentation/mediaaccessibility).
    /// This ensures that selection is automatically restored in other apps relying on Media Accessibility.
    ///
    /// You can use `mediaCharacteristics` to retrieve available characteristics. This method does nothing if attempting
    /// to set an option that is not supported.
    func select(mediaOption: MediaSelectionOption, for characteristic: AVMediaCharacteristic) {
        guard let item = queuePlayer.currentItem, let selector = mediaSelector(for: characteristic),
              selector.supports(mediaSelectionOption: mediaOption) else {
            return
        }
        queuePlayer.setMediaSelectionCriteria(nil, forMediaCharacteristic: characteristic)
        selector.select(mediaOption: mediaOption, on: item, in: queuePlayer)
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

    /// The current media option for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The current option or `nil` if none.
    ///
    /// Unlike `selectedMediaOption(for:)` this method provides the currently applied option. This method can
    /// be useful if you need to access the actual selection made by `select(mediaOption:for:)` for `.automatic`
    /// and `.off` options. Forced options might be returned where applicable.
    func currentMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        guard let option = mediaSelectionContext.selectedOption(for: characteristic) else { return .off }
        return .on(option)
    }

    /// Applies automatic selection criteria for media that has the specified media characteristic.
    /// 
    /// - Parameters:
    ///   - preferredLanguages: An Array of strings containing language identifiers, in order of desirability, that are 
    ///     preferred for selection. Languages can be indicated via BCP 47 language identifiers or via ISO 639-2/T language
    ///     codes.
    ///   - characteristic: The media characteristic for which the selection criteria are to be applied.
    ///     Supported values include .audible, .legible, and .visual.
    ///
    /// Criteria will be applied to an `AVPlayerItem` instance when is ready to play. They are cleared when a selection
    /// is made using `select(mediaOption:for`).
    func setMediaSelectionCriteria(preferredLanguages languages: [String], for characteristic: AVMediaCharacteristic) {
        if let item = queuePlayer.currentItem {
            mediaSelectionContext.reset(for: characteristic, in: item)
        }

        if !languages.isEmpty {
            let criteria = AVPlayerMediaSelectionCriteria(
                preferredLanguages: languages + Self.preferredLanguages(for: characteristic),
                preferredMediaCharacteristics: nil
            )
            queuePlayer.setMediaSelectionCriteria(criteria, forMediaCharacteristic: characteristic)
        }
        else {
            queuePlayer.setMediaSelectionCriteria(nil, forMediaCharacteristic: characteristic)
        }
    }

    private func mediaSelector(for characteristic: AVMediaCharacteristic) -> MediaSelector? {
        guard let group = mediaSelectionContext.group(for: characteristic) else { return nil }
        switch characteristic {
        case .audible:
            return AudibleMediaSelector(group: group)
        case .legible:
            return LegibleMediaSelector(group: group)
        default:
            return nil
        }
    }
}
