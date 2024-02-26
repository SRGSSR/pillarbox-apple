//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct ItemState {
    static let empty = Self(item: nil, error: nil)

    let item: AVPlayerItem?
    let error: Error?

    init(item: AVPlayerItem?, error: Error?) {
        self.item = item

        if let error, item != nil {
            self.error = ItemError.localizedError(from: error)
        }
        else {
            self.error = nil
        }
    }
}
