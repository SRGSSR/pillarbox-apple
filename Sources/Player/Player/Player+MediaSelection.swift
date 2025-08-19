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
        properties.mediaSelectionProperties.characteristics
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
    /// You can use `mediaSelectionCharacteristics` to retrieve available characteristics.
    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        guard let selection = properties.mediaSelectionProperties.selection, let selector = mediaSelector(for: characteristic) else {
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
    /// You can use `mediaSelectionCharacteristics` to retrieve available characteristics. This method does nothing when
    /// attempting to set an option that is not supported.
    func select(mediaOption: MediaSelectionOption, for characteristic: AVMediaCharacteristic) {
        guard let item = queuePlayer.currentItem, let selector = mediaSelector(for: characteristic),
              selector.supports(mediaSelectionOption: mediaOption) else {
            return
        }
        let selectionCriteria = queuePlayer.mediaSelectionCriteria(forMediaCharacteristic: characteristic)
        let updatedSelectionCriteria = selector.select(mediaOption: mediaOption, on: item, with: selectionCriteria)
        queuePlayer.setMediaSelectionCriteria(updatedSelectionCriteria, forMediaCharacteristic: characteristic)
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
    /// - Returns: The current option.
    ///
    /// Unlike `selectedMediaOption(for:)` this method provides the currently applied option. This method can
    /// be useful if you need to access the actual selection made by `select(mediaOption:for:)` for `.automatic`
    /// and `.off` options (forced options might be returned where applicable).
    func currentMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        properties.currentMediaOption(for: characteristic)
    }

    /// Sets media selection preferred languages for the specified media characteristic.
    ///
    /// - Parameters:
    ///   - languages: An Array of strings containing language identifiers, in order of desirability, that are
    ///     preferred for selection. Languages can be indicated via BCP 47 language identifiers or via ISO 639-2/T
    ///     language codes. Use an empty list to prefer no language selection if possible.
    ///   - characteristic: The media characteristic for which the selection criteria are to be applied. Supported values
    ///     include `.audible`, `.legible`, and `.visual`.
    ///
    /// This method can be used to override the default media option selection for some characteristic, e.g., to start
    /// playback with a predefined language for audio and/or subtitles.
    ///
    /// > Important: Media selection only works when HLS playlists are correctly formatted. If selection does not behave
    ///   as expected, see the troubleshooting section in <doc:stream-encoding-and-packaging-advice-article> to identify
    ///   which requirements may not have been met.
    func setMediaSelection(preferredLanguages languages: [String], for characteristic: AVMediaCharacteristic) {
        if let item = queuePlayer.currentItem {
            properties.mediaSelectionProperties.reset(for: characteristic, in: item)
        }
        let selectionCriteria = AVPlayerMediaSelectionCriteria(
            preferredLanguages: languages,
            preferredMediaCharacteristics: Self.preferredMediaCharacteristics(for: characteristic)
        )
        queuePlayer.setMediaSelectionCriteria(selectionCriteria, forMediaCharacteristic: characteristic)
    }

    /// Resets media selection preferred languages for the specified media characteristic.
    ///
    /// This method removes any overrides, returning the behavior to default media option selection.
    func resetMediaSelectionPreferredLanguages(for characteristic: AVMediaCharacteristic) {
        queuePlayer.setMediaSelectionCriteria(nil, forMediaCharacteristic: characteristic)
    }

    /// Returns media selection preferred languages for the specified media characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    func mediaSelectionPreferredLanguages(for characteristic: AVMediaCharacteristic) -> [String] {
        guard let selectionCriteria = queuePlayer.mediaSelectionCriteria(forMediaCharacteristic: characteristic),
              let preferredLanguages = selectionCriteria.preferredLanguages else {
            return []
        }
        return preferredLanguages
    }

    private func mediaSelector(for characteristic: AVMediaCharacteristic) -> MediaSelector? {
        guard let group = properties.mediaSelectionProperties.group(for: characteristic) else { return nil }
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

public extension Player {
    /// An array of text style rules that specify the formatting and presentation of Web Video Text Tracks (WebVTT)
    /// subtitles.
    ///
    /// Text style rules apply only to WebVTT subtitles. They don’t apply to other subtitle formats and legible text
    /// or if WebVTT subtitles provide style information.
    var textStyleRules: [AVTextStyleRule] {
        get {
            textStyleRulesPublisher.value
        }
        set {
            textStyleRulesPublisher.send(newValue)
        }
    }
}
