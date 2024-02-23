//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct ItemUpdate {
    static var empty: Self {
        .init(item: nil, error: nil)
    }

    let item: AVPlayerItem?
    let error: Error?

    init(item: AVPlayerItem?, error: Error?) {
        self.item = item
        self.error = item != nil ? error : nil
    }
}
