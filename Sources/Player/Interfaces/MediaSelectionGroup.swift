//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

protocol MediaSelectionGroup {
    var group: AVMediaSelectionGroup { get }
    var options: [MediaSelectionOption] { get }

    init(group: AVMediaSelectionGroup)

    func selectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption
    func select(mediaOption: MediaSelectionOption, in selection: AVMediaSelection, for item: AVPlayerItem)
}

extension MediaSelectionGroup {
    func activeMediaOption(in selection: AVMediaSelection) -> AVMediaSelectionOption? {
        selection.selectedMediaOption(in: group)
    }
}
