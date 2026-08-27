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

    /// Returns the preferred audio options from a list of options.
    ///
    /// The "Audio Descriptions" Accessibility setting is taken into account to return either a list containing
    /// non-AD options preferably (setting Off), or AD options preferably (setting On).
    static func preferredAudioOptions(from options: [AVMediaSelectionOption]) -> [AVMediaSelectionOption] {
        let preferredCharacteristics = MAPreferredMediaCharacteristics(for: .audible)
        if !preferredCharacteristics.isEmpty {
            return preferredMediaSelectionOptions(from: options, withMediaCharacteristics: preferredCharacteristics)
        }
        else {
            return preferredMediaSelectionOptions(from: options, withoutMediaCharacteristics: [.describesVideoForAccessibility])
        }
    }

    /// Returns the preferred captioning options from a list of options.
    ///
    /// The "Closed Captions + SDH" Accessibility setting is taken into account to return either a list containing
    /// non-CC / non-SDH options preferably (setting Off), or CC / SDH options preferably (setting On).
    static func preferredCaptioningOptions(from options: [AVMediaSelectionOption]) -> [AVMediaSelectionOption] {
        let unforcedOptions = mediaSelectionOptions(from: options, withoutMediaCharacteristics: [.containsOnlyForcedSubtitles])
        let preferredCharacteristics = MAPreferredMediaCharacteristics(for: .legible)
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
