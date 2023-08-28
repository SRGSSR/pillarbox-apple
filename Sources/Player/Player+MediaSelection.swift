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
            return MACaptionAppearanceCopySelectedLanguages(.user).takeUnretainedValue() as? [String] ?? []
        default:
            return []
        }
    }

    // swiftlint:disable:next discouraged_optional_collection
    private static func preferredMediaCharacteristics(for characteristic: AVMediaCharacteristic) -> [AVMediaCharacteristic]? {
        switch characteristic {
        case .audible:
            return MAAudibleMediaCopyPreferredCharacteristics().takeRetainedValue() as? [AVMediaCharacteristic]
        case .legible:
            return MACaptionAppearanceCopyPreferredCaptioningMediaCharacteristics(.user).takeRetainedValue() as? [AVMediaCharacteristic]
        default:
            return []
        }
    }

    /// The list of media options associated with a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The list of options associated with the characteristic.
    ///
    /// Use `mediaSelectionCharacteristics` to retrieve available characteristics.
    func mediaSelectionOptions(for characteristic: AVMediaCharacteristic) -> [MediaSelectionOption] {
        guard let selector = mediaSelector(for: characteristic) else { return [] }
        return selector.mediaSelectionOptions()
    }

    /// The currently selected media option for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The selected option.
    ///
    /// You can use `mediaCharacteristics` to retrieve available characteristics.
    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        guard let selection = mediaSelectionContext.selection, let selector = mediaSelector(for: characteristic) else {
            return .off
        }

        let selectionCriteria = queuePlayer.mediaSelectionCriteria(forMediaCharacteristic: characteristic)
        let option = selector.selectedMediaOption(in: selection, with: selectionCriteria)
        return selector.supports(mediaSelectionOption: option) ? option : .off
    }

    /// Selects a media option for a characteristic.
    ///
    /// - Parameters:
    ///   - mediaOption: The option to select.
    ///   - characteristic: The characteristic.
    ///
    /// You can use `mediaCharacteristics` to retrieve available characteristics. This method does nothing if attempting
    /// to set an option that is not supported.
    func select(mediaOption: MediaSelectionOption, for characteristic: AVMediaCharacteristic) {
        guard let item = queuePlayer.currentItem, let selector = mediaSelector(for: characteristic),
              selector.supports(mediaSelectionOption: mediaOption) else {
            return
        }
        let selectionCriteria = queuePlayer.mediaSelectionCriteria(forMediaCharacteristic: characteristic)
        if let updatedSelectionCriteria = selector.select(mediaOption: mediaOption, on: item, with: selectionCriteria) {
            queuePlayer.setMediaSelectionCriteria(updatedSelectionCriteria, forMediaCharacteristic: characteristic)
        }
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

    /// Sets media selection preferred languages for the specified media characteristic.
    ///
    /// - Parameters:
    ///   - preferredLanguages: An Array of strings containing language identifiers, in order of desirability, that are 
    ///     preferred for selection. Languages can be indicated via BCP 47 language identifiers or via ISO 639-2/T 
    ///     language codes.
    ///   - characteristic: The media characteristic for which the selection criteria are to be applied.
    ///     Supported values include `.audible`, `.legible`, and `.visual`.
    ///
    /// Criteria will be applied to an `AVPlayerItem` instance when is ready to play.
    func setMediaSelection(preferredLanguages languages: [String], for characteristic: AVMediaCharacteristic) {
        if let item = queuePlayer.currentItem {
            mediaSelectionContext.reset(for: characteristic, in: item)
        }

        if !languages.isEmpty {
            let selectionCriteria = queuePlayer.mediaSelectionCriteria(forMediaCharacteristic: characteristic) ?? AVPlayerMediaSelectionCriteria(
                preferredLanguages: Self.preferredLanguages(for: characteristic),
                preferredMediaCharacteristics: Self.preferredMediaCharacteristics(for: characteristic)
            )
            queuePlayer.setMediaSelectionCriteria(selectionCriteria.adding(preferredLanguages: languages), forMediaCharacteristic: characteristic)
        }
        else {
            queuePlayer.setMediaSelectionCriteria(nil, forMediaCharacteristic: characteristic)
        }
    }

    /// Returns media selection preferred languages for the specified media characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    func mediaSelectionPreferredLanguages(for characteristic: AVMediaCharacteristic) -> [String] {
        guard let selectionCriteria = queuePlayer.mediaSelectionCriteria(forMediaCharacteristic: characteristic) else {
            return []
        }
        return selectionCriteria.preferredLanguages ?? []
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
