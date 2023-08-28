//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility

/// The default selector for audible options.
struct AudibleMediaSelector: MediaSelector {
    let group: AVMediaSelectionGroup

    func mediaSelectionOptions() -> [MediaSelectionOption] {
        let options = AVMediaSelectionGroup.sortedMediaSelectionOptions(from: group.options)
        return options.count > 1 ? options.map { .on($0) } : []
    }

    func selectedMediaOption(in selection: AVMediaSelection, of player: AVPlayer) -> MediaSelectionOption {
        if let option = selection.selectedMediaOption(in: group) {
            return .on(option)
        }
        else {
            return .off
        }
    }

    func select(mediaOption: MediaSelectionOption, on item: AVPlayerItem, of player: AVPlayer) {
        switch mediaOption {
        case let .on(option):
            if let languageCode = option.languageCode {
                // TODO: In a private method
                if let selectionCriteria = player.mediaSelectionCriteria(forMediaCharacteristic: .audible) {
                    player.setMediaSelectionCriteria(
                        selectionCriteria.adding(preferredLanguages: [languageCode]),
                        forMediaCharacteristic: .audible
                    )
                }
                else {
                    let selectionCriteria = AVPlayerMediaSelectionCriteria(
                        preferredLanguages: [languageCode],
                        preferredMediaCharacteristics: MAAudibleMediaCopyPreferredCharacteristics().takeRetainedValue() as? [AVMediaCharacteristic]
                    )
                    player.setMediaSelectionCriteria(selectionCriteria, forMediaCharacteristic: .audible)
                }
            }
            item.select(option, in: group)
        default:
            break
        }
    }
}
