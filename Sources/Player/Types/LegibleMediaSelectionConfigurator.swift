//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct LegibleMediaSelectionConfigurator: MediaSelectionConfigurator {
    private let provider: MediaSelectionProvider

    init(provider: MediaSelectionProvider) {
        self.provider = provider
    }

    func mediaSelections(from selection: AVMediaSelection, withLanguages languages: [String]) -> [AVMediaSelection] {
        languages.map { mediaSelection(from: selection, withLanguage: $0) }
    }

    private func mediaSelection(from selection: AVMediaSelection, withLanguage language: String) -> AVMediaSelection {
        guard let provider = provider.mediaSelectorProvider(for: .legible) else { return selection }
        let options = AVMediaSelectionGroup.mediaSelectionOptions(from: provider.options, filteredAndSortedAccordingToPreferredLanguages: [language])
        return provider.selecting(options.first, in: selection)
    }
}
