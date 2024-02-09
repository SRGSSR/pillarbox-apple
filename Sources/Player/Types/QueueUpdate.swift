//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct QueueUpdate {
    static var initial: Self {
        .init(assets: [], transition: .advance(to: nil))
    }

    let assets: [any Assetable]
    let transition: ItemTransition
}
