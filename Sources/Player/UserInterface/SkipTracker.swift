//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import SwiftUI

/// A skip.
public enum Skip {
    /// Backward skip.
    case backward

    /// Forward skip.
    case forward
}

/// An observable object managing skips.
@available(iOS 16, *)
@available(tvOS, unavailable)
public final class SkipTracker: ObservableObject {
    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?

    /// The current tracker state.
    @Published public private(set) var state: State = .idle

    /// Create a tracker managing skips.
    ///
    /// - Parameters:
    ///   - count: The required number of requests which to be made to enable skip mode.
    ///   - delay: The delay after which skip mode is disabled.
    public init(count: Int = 2, delay: TimeInterval = 0.4) {
    }

    /// Request a skip in a given direction.
    ///
    /// - Parameter skip: The skip direction.
    public func requestSkip(_ skip: Skip) {
    }
}

public extension SkipTracker {
    /// A skip tracker state.
    enum State: Equatable {
        /// Idle.
        case idle

        /// Skipping backward.
        case skippingBackward(TimeInterval)

        /// Skipping forward.
        case skippingForward(TimeInterval)
    }
}

@available(iOS 16, *)
@available(tvOS, unavailable)
public extension View {
    /// Binds a skip tracker to a player.
    ///
    /// - Parameters:
    ///   - skipTracker: The skip tracker to bind.
    ///   - player: The player to observe.
    func bind(_ skipTracker: SkipTracker, to player: Player?) -> some View {
        onAppear {
            skipTracker.player = player
        }
        .onChange(of: player) { newValue in
            skipTracker.player = newValue
        }
    }
}
