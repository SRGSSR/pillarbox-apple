//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import OSLog

extension Logger {
    init(category: String) {
        self.init(subsystem: "ch.srgssr.pillarbox.player", category: category)
    }
}
