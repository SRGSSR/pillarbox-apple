//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

enum ItemQueueUpdate {
    case assets([any Assetable])
    case itemTransition(ItemTransition)
}

struct ItemQueue {
    static var initial: Self {
        .init(assets: [], itemTransition: .advance(to: nil))
    }

    let assets: [any Assetable]
    let itemTransition: ItemTransition

    init(assets: [any Assetable], itemTransition: ItemTransition) {
        self.assets = assets
        self.itemTransition = !assets.isEmpty ? itemTransition : .advance(to: nil)
    }

    func updated(with update: ItemQueueUpdate) -> Self {
        switch update {
        case let .assets(assets):
            return .init(assets: assets, itemTransition: itemTransition)
        case let .itemTransition(itemTransition):
            return .init(assets: assets, itemTransition: itemTransition)
        }
    }
}
