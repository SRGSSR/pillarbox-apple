//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility

extension AVMediaSelectionGroup {
    /// Returns media selection options where options with the provided characteristics are preferred.
    ///
    /// When several options have the same language code in the original list, those which have the provided media
    /// characteristics are preferred.
    static func preferredMediaSelectionOptions(
        from options: [AVMediaSelectionOption],
        withMediaCharacteristics characteristics: [AVMediaCharacteristic]
    ) -> [AVMediaSelectionOption] {
        let withOptions = Dictionary(grouping: mediaSelectionOptions(from: options, withMediaCharacteristics: characteristics)) { option in
            option.languageCode
        }
        return Dictionary(grouping: options) { option in
            option.languageCode
        }
        .merging(withOptions) { _, new in new }
        .values
        .flatMap(\.self)
    }

    /// Returns media selection options where options without the provided characteristics are preferred.
    ///
    /// When several options have the same language code in the original list, those which don't have the provided media
    /// characteristics are preferred.
    static func preferredMediaSelectionOptions(
        from options: [AVMediaSelectionOption],
        withoutMediaCharacteristics characteristics: [AVMediaCharacteristic]
    ) -> [AVMediaSelectionOption] {
        let withoutOptions = Dictionary(grouping: mediaSelectionOptions(from: options, withoutMediaCharacteristics: characteristics)) { option in
            option.languageCode
        }
        return Dictionary(grouping: options) { option in
            option.languageCode
        }
        .merging(withoutOptions) { _, new in new }
        .values
        .flatMap(\.self)
    }

    /// Returns the preferred captioning options from a list of options.
    ///
    /// The "Closed Captions + SDH" Accessibility setting is taken into account to return either a list containing
    /// non-CC / non-SDH options preferably (setting Off), or CC / SDH-options preferably (setting On).
    static func preferredCaptioningOptions(from options: [AVMediaSelectionOption]) -> [AVMediaSelectionOption] {
        // swiftlint:disable:next line_length
        guard let preferredCharacteristics = MACaptionAppearanceCopyPreferredCaptioningMediaCharacteristics(.user).takeRetainedValue() as? [AVMediaCharacteristic] else {
            return options
        }
        let unforcedOptions = mediaSelectionOptions(from: options, withoutMediaCharacteristics: [.containsOnlyForcedSubtitles])
        if !preferredCharacteristics.isEmpty {
            return preferredMediaSelectionOptions(from: unforcedOptions, withMediaCharacteristics: preferredCharacteristics)
        }
        else {
            return preferredMediaSelectionOptions(from: unforcedOptions, withoutMediaCharacteristics: [
                .describesMusicAndSoundForAccessibility,
                .transcribesSpokenDialogForAccessibility
            ])
        }
    }

    static func sortedMediaSelectionOptions(from options: [AVMediaSelectionOption]) -> [AVMediaSelectionOption] {
        options.sorted(by: <)
    }
}
