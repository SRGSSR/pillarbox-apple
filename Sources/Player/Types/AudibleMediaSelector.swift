//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AudibleMediaSelector: MediaSelector {
    let group: AVMediaSelectionGroup

    func mediaSelectionOptions() -> [MediaSelectionOption] {
        let options = AVMediaSelectionGroup.sortedMediaSelectionOptions(from: group.options)
        return options.count > 1 ? options.map { .on($0) } : []
    }

    func selectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption {
        if let option = selection.selectedMediaOption(in: group) {
            return .on(option)
        }
        else {
            return .off
        }
    }

    func select(mediaOption: MediaSelectionOption, on item: AVPlayerItem) {
        switch mediaOption {
        case let .on(option):
            item.select(option, in: group)
        default:
            break
        }
    }
}
