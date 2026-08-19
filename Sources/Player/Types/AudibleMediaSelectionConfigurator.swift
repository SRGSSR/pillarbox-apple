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

    func mediaSelections(from selection: AVMediaSelection, withLanguages languages: [String]) -> [AVMediaSelection] {
        languages.compactMap { language in
            forcedLegibleMediaSelection(from: audibleMediaSelection(from: selection, withLanguage: language), withLanguage: language)
        }
    }

    private func audibleMediaSelection(from selection: AVMediaSelection, withLanguage language: String) -> AVMediaSelection {
        guard let provider = provider.mediaSelectorProvider(for: .audible) else { return selection }
        let options = AVMediaSelectionGroup.mediaSelectionOptions(from: provider.options, filteredAndSortedAccordingToPreferredLanguages: [language])
        return provider.selecting(options.first, in: selection)
    }

    private func forcedLegibleMediaSelection(from selection: AVMediaSelection, withLanguage language: String) -> AVMediaSelection? {
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
