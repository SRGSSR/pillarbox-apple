//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MediaSelectionContext {
    private let mediaSelection: AVMediaSelection
    private let groups: [AVMediaCharacteristic: AVMediaSelectionGroup]

    init(mediaSelection: AVMediaSelection, groups: [AVMediaCharacteristic: AVMediaSelectionGroup]) {
        self.mediaSelection = mediaSelection
        self.groups = groups
    }

    func mediaSelections(withLanguages languages: [String], for characteristic: AVMediaCharacteristic) -> [AVMediaSelection] {
        languages.compactMap { mediaSelection(withLanguage: $0, for: characteristic) }
    }

    // TODO: Rough implementation. Must be rewritten.
    private func mediaSelection(withLanguage language: String, for characteristic: AVMediaCharacteristic) -> AVMediaSelection {
        guard let group = groups[characteristic],
              let selection = mediaSelection.mutableCopy() as? AVMutableMediaSelection else {
            return mediaSelection
        }
        let option = group.options.first { $0.languageCode == language }
        selection.select(option, in: group)
        return selection
    }
}
