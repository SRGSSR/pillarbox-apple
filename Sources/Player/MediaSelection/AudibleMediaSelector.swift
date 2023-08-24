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

    // Question: Can this be moved for all characteristics to Player+MediaOption? What about persisted vs non-persisted then?

    func select(mediaOption: MediaSelectionOption, on item: AVPlayerItem, in player: AVPlayer) {
        switch mediaOption {
        case let .on(option):
            if let languageCode = option.languageCode {
                if let selectionCriteria = player.mediaSelectionCriteria(forMediaCharacteristic: .audible) {
                    player.setMediaSelectionCriteria(
                        selectionCriteria.adding(preferredLanguages: [languageCode]),
                        forMediaCharacteristic: .audible
                    )
                }
                else {
                    let selectionCriteria = AVPlayerMediaSelectionCriteria(preferredLanguages: [languageCode], preferredMediaCharacteristics: nil)
                    player.setMediaSelectionCriteria(selectionCriteria, forMediaCharacteristic: .audible)
                }
            }
            item.select(option, in: group)
        default:
            break
        }
    }
}
