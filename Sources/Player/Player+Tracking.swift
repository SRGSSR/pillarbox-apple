//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public extension Player {
    /// The list of current session identifiers associated with trackers of a specific type.
    func currentSessionIdentifiers<T>(trackedBy type: T.Type) -> [String] where T: PlayerItemTracker {
        guard let currentItem else { return [] }
        return currentItem.sessionIdentifiers(trackedBy: type)
    }
}
