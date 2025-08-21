//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility

/// The default selector for legible options.
struct LegibleMediaSelector: MediaSelector {
    let group: AVMediaSelectionGroup

    func mediaSelectionOptions() -> [MediaSelectionOption] {
        var options: [MediaSelectionOption] = [.automatic, .off]
        let preferredCaptioningOptions = preferredCaptioningOptions(from: group.options)
        options.append(
            contentsOf: AVMediaSelectionGroup.sortedMediaSelectionOptions(from: preferredCaptioningOptions)
                .map { .on($0) }
        )
        return options
    }

    func selectedMediaOption(
        in selection: AVMediaSelection?,
        with selectionCriteria: AVPlayerMediaSelectionCriteria?
    ) -> MediaSelectionOption {
        guard let preferredLanguages = selectionCriteria?.preferredLanguages, !preferredLanguages.isEmpty else {
            return persistedMediaOption(in: selection)
        }
        if let option = selection?.selectedMediaOption(in: group) {
            return .on(option)
        }
        else {
            return .off
        }
    }

    private func persistedMediaOption(in selection: AVMediaSelection?) -> MediaSelectionOption {
        switch MACaptionAppearanceGetDisplayType(.user) {
        case .alwaysOn:
            if let option = selection?.selectedMediaOption(in: group) {
                return .on(option)
            }
            else {
                return .off
            }
        case .automatic:
            return .automatic
        default:
            return .off
        }
    }

    func select(
        mediaOption: MediaSelectionOption,
        on item: AVPlayerItem,
        with selectionCriteria: AVPlayerMediaSelectionCriteria?
    ) -> AVPlayerMediaSelectionCriteria? {
        switch mediaOption {
        case .automatic:
            MACaptionAppearanceSetDisplayType(.user, .automatic)
            item.selectMediaOptionAutomatically(in: group)
        case .off:
            MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
            item.selectMediaOptionAutomatically(in: group)
        case let .on(option):
            MACaptionAppearanceSetDisplayType(.user, .alwaysOn)
            if let languageCode = option.languageCode {
                MACaptionAppearanceAddSelectedLanguage(.user, languageCode as CFString)
            }
            item.select(option, in: group)
        }
        return nil
    }

    /// Returns the preferred captioning options from a list of options.
    ///
    /// The "Closed Captions + SDH" Accessibility setting is taken into account to return either a list containing
    /// non-CC / non-SDH options preferably (setting Off), or CC / SDH-options preferably (setting On).
    private func preferredCaptioningOptions(from options: [AVMediaSelectionOption]) -> [AVMediaSelectionOption] {
        // swiftlint:disable:next line_length
        guard let preferredCharacteristics = MACaptionAppearanceCopyPreferredCaptioningMediaCharacteristics(.user).takeRetainedValue() as? [AVMediaCharacteristic] else {
            return options
        }
        let unforcedOptions = AVMediaSelectionGroup.mediaSelectionOptions(
            from: options,
            withoutMediaCharacteristics: [.containsOnlyForcedSubtitles]
        )
        if !preferredCharacteristics.isEmpty {
            return AVMediaSelectionGroup.preferredMediaSelectionOptions(from: unforcedOptions, withMediaCharacteristics: preferredCharacteristics)
        }
        else {
            return AVMediaSelectionGroup.preferredMediaSelectionOptions(from: unforcedOptions, withoutMediaCharacteristics: [
                .describesMusicAndSoundForAccessibility,
                .transcribesSpokenDialogForAccessibility
            ])
        }
    }
}
