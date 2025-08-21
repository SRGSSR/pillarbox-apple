//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// The default selector for audible options.
struct AudibleMediaSelector: MediaSelector {
    let group: AVMediaSelectionGroup

    func mediaSelectionOptions() -> [MediaSelectionOption] {
        let options = AVMediaSelectionGroup.sortedMediaSelectionOptions(from: group.options)
        return options.count > 1 ? options.map { .on($0) } : []
    }

    func selectedMediaOption(
        in selection: AVMediaSelection?,
        with selectionCriteria: AVPlayerMediaSelectionCriteria?
    ) -> MediaSelectionOption {
        if let option = selection?.selectedMediaOption(in: group) {
            return .on(option)
        }
        else {
            return .off
        }
    }

    func select(
        mediaOption: MediaSelectionOption,
        on item: AVPlayerItem,
        with selectionCriteria: AVPlayerMediaSelectionCriteria?
    ) -> AVPlayerMediaSelectionCriteria? {
        switch mediaOption {
        case let .on(option):
            item.select(option, in: group)
            return mediaSelectionCriteria(from: selectionCriteria, for: option)
        default:
            return nil
        }
    }

    private func mediaSelectionCriteria(
        from selectionCriteria: AVPlayerMediaSelectionCriteria?,
        for option: AVMediaSelectionOption
    ) -> AVPlayerMediaSelectionCriteria? {
        guard let languageCode = option.languageCode else { return nil }
        if let selectionCriteria {
            return selectionCriteria.selectionCriteria(
                byAdding: [languageCode],
                with: audibleCharacteristics(for: option)
            )
        }
        else {
            return AVPlayerMediaSelectionCriteria(
                preferredLanguages: [languageCode],
                preferredMediaCharacteristics: audibleCharacteristics(for: option)
            )
        }
    }

    private func audibleCharacteristics(for option: AVMediaSelectionOption) -> [AVMediaCharacteristic] {
        option.hasMediaCharacteristic(.describesVideoForAccessibility) ? [.describesVideoForAccessibility] : []
    }
}
