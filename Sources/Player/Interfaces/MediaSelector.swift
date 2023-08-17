//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

protocol MediaSelector {
    var group: AVMediaSelectionGroup { get }

    init(group: AVMediaSelectionGroup)

    func mediaSelectionOptions() -> [MediaSelectionOption]
    func selectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption
    func select(
        mediaOption: MediaSelectionOption,
        otherSelectedOptions: [AVMediaCharacteristic: AVMediaSelectionOption],
        on item: AVPlayerItem
    )
}
