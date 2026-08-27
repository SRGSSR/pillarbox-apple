//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AudibleMediaSelectionConfigurator: MediaSelectionConfigurator {
    private let provider: MediaSelectionProvider

    init(provider: MediaSelectionProvider) {
        self.provider = provider
    }

    func allMediaSelections(from selection: AVMediaSelection) -> [AVMediaSelection] {
        guard let provider = provider.mediaSelectorProvider(for: .audible) else { return [selection] }
        return AVMediaSelectionGroup.preferredAudioOptions(from: provider.options)
            .map { option in
                guard let language = option.languageCode else {
                    return provider.selecting(option, in: selection)
                }
                let audibleSelection = provider.selecting(option, in: selection)
                return forcedLegibleMediaSelection(from: audibleSelection, withLanguage: language)
            }
    }

    func mediaSelections(from selection: AVMediaSelection, withLanguages languages: [String]) -> [AVMediaSelection] {
        languages.compactMap { mediaSelection(from: selection, withLanguage: $0) }
    }

    private func mediaSelection(from selection: AVMediaSelection, withLanguage language: String) -> AVMediaSelection {
        guard let provider = provider.mediaSelectorProvider(for: .audible) else { return selection }
        let options = AVMediaSelectionGroup.mediaSelectionOptions(
            from: AVMediaSelectionGroup.preferredAudioOptions(from: provider.options),
            filteredAndSortedAccordingToPreferredLanguages: [language]
        )
        let audibleSelection = provider.selecting(options.first, in: selection)
        return forcedLegibleMediaSelection(from: audibleSelection, withLanguage: language)
    }

    private func forcedLegibleMediaSelection(from selection: AVMediaSelection, withLanguage language: String) -> AVMediaSelection {
        guard let provider = provider.mediaSelectorProvider(for: .legible) else { return selection }
        let options = AVMediaSelectionGroup.mediaSelectionOptions(
            from: AVMediaSelectionGroup.mediaSelectionOptions(
                from: provider.options, withMediaCharacteristics: [.containsOnlyForcedSubtitles]
            ),
            filteredAndSortedAccordingToPreferredLanguages: [language]
        )
        return provider.selecting(options.first, in: selection)
    }
}
