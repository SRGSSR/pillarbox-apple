//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A type that represents a tracker.
public protocol PlayerItemTracker {
  /// Called when a tracker is enabled for a player.
  /// - Parameter player: The player to which the tracker must be attached.
  func enable(for player: Player)

  /// Called when a tracker is disabled for a player.
  func disable()
}
