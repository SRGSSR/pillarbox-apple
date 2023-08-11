//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

protocol MediaSelectionGroup {
    var options: [MediaSelectionOption] { get }

    init(group: AVMediaSelectionGroup)

    func selectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption
    func select(mediaOption: MediaSelectionOption, in item: AVPlayerItem)
}
