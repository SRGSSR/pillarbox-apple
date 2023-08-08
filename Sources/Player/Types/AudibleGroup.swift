//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AudibleGroup: MediaSelectionGroup {
    let group: AVMediaSelectionGroup

    var options: [MediaSelectionOption] {
        guard group.options.count > 1 else { return [] }
        return group.options.map { .enabled($0) }
    }

    func selectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption {
        if let option = selection.selectedMediaOption(in: group) {
            return .enabled(option)
        }
        else {
            return .disabled
        }
    }

    func select(mediaOption: MediaSelectionOption, in item: AVPlayerItem) {
        switch mediaOption {
        case let .enabled(option):
            item.select(option, in: group)
        default:
            item.select(nil, in: group)
        }
    }
}
