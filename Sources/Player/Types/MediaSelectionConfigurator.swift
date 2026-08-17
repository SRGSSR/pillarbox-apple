//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MediaSelectionConfigurator {
    private let selection: AVMediaSelection
    private let provider: MediaSelectionProvider

    init(selection: AVMediaSelection, provider: MediaSelectionProvider) {
        self.selection = selection
        self.provider = provider
    }

    func mediaSelections(withLanguages languages: [String], for characteristic: AVMediaCharacteristic) -> [AVMediaSelection] {
        languages.compactMap { mediaSelection(withLanguage: $0, for: characteristic) }
    }

    private func mediaSelection(withLanguage language: String, for characteristic: AVMediaCharacteristic) -> AVMediaSelection {
        guard let provider = provider.mediaSelectorProvider(for: characteristic) else { return selection }
        let option = provider.options.first { option in
            guard let languageCode = option.languageCode else { return false }
            return languageCode == language || languageCode.hasPrefix(language)
        }
        return provider.selecting(option, in: selection)
    }
}
