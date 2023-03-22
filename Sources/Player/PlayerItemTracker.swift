//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Protocol for player item trackers.
public protocol PlayerItemTracker: AnyObject {
    /// The type of metadata required by the tracker.
    associatedtype Metadata

    /// Initialize the tracker.
    init()

    /// Called when the tracker is enabled for a player.
    /// - Parameter player: The player for which the tracker must be enabled.
    func enable(for player: Player)

    /// Called when the tracker metadata is updated.
    func update(metadata: Metadata)

    /// Called when the tracker is disabled.
    func disable()
}
