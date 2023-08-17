//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AudibleMediaSelector: MediaSelector {
    let group: AVMediaSelectionGroup

    func mediaSelectionOptions() -> [MediaSelectionOption] {
        let options = group.sortedOptions()
        return options.count > 1 ? options : []
    }

    func selectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption {
        if let option = selection.selectedMediaOption(in: group) {
            return .enabled(option)
        }
        else {
            return .disabled
        }
    }

    func select(mediaOption: MediaSelectionOption, on item: AVPlayerItem) {
        switch mediaOption {
        case let .enabled(option):
            item.select(option, in: group)
        default:
            break
        }
    }
}
