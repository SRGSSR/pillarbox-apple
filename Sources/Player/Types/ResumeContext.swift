//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct ResumeContext {
    let position: Position
    let itemId: UUID

    init(position: Position, in item: PlayerItem) {
        self.position = position
        self.itemId = item.id
    }
}
