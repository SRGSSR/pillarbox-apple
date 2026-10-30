//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A player configuration.
///
/// The configuration controls behaviors set at player creation time and that cannot be changed afterwards. Create a
/// configuration with its initializer, or start from ``default`` and adjust its properties, then pass it to
/// ``Player/init(items:configuration:)`` or ``Player/init(item:configuration:)``. The configuration of an existing
/// player is available from ``Player/configuration``.
public struct PlayerConfiguration {
    /// The default configuration.
    public static let `default` = Self()

    /// A Boolean describing whether the player allows switching to external playback mode.
    ///
    /// External playback mode includes AirPlay. The default value is `true`.
    public var allowsExternalPlayback: Bool

    /// A Boolean describing whether the player automatically switches to external playback when the screen is
    /// mirrored.
    ///
    /// This property has no effect when ``allowsExternalPlayback`` is `false`. The default value is `false`.
    public var usesExternalPlaybackWhileMirroring: Bool

    /// A Boolean describing whether video playback prevents display and device sleep.
    ///
    /// The default value is `true`.
    public var preventsDisplaySleepDuringVideoPlayback: Bool

    /// The mode used when navigating between items of the playback queue.
    ///
    /// The default value is ``NavigationMode/smart(interval:)`` with an interval of 3 seconds.
    public var navigationMode: NavigationMode

    /// The interval by which skipping backward moves the playhead, in seconds.
    ///
    /// The interval is used by ``Player/skipBackward(completion:)`` and by the Control Center. It must be greater
    /// than zero. The default value is 10 seconds.
    public var backwardSkipInterval: TimeInterval {
        didSet {
            assert(backwardSkipInterval > 0)
        }
    }

    /// The interval by which skipping forward moves the playhead, in seconds.
    ///
    /// The interval is used by ``Player/skipForward(completion:)`` and by the Control Center. It must be greater than
    /// zero. The default value is 10 seconds.
    public var forwardSkipInterval: TimeInterval {
        didSet {
            assert(forwardSkipInterval > 0)
        }
    }

    /// A Boolean describing whether the player is permitted to play content on networks with Low Data Mode
    /// enabled.
    ///
    /// When this property is set to `false`, playback fails with a network availability error on constrained networks.
    /// This option is therefore mostly useful for players associated with non-essential content, such as animated
    /// background videos used purely for visual enhancement. The default value is `true`.
    public var allowsConstrainedNetworkAccess: Bool

    /// The number of items to preload.
    let preloadedItems = 2

    /// Creates a player configuration.
    ///
    /// - Parameters:
    ///   - allowsExternalPlayback: A Boolean describing whether the player allows switching to external playback mode.
    ///   - usesExternalPlaybackWhileMirroring: A Boolean describing whether the player automatically switches to
    ///     external playback when the screen is mirrored.
    ///   - preventsDisplaySleepDuringVideoPlayback: A Boolean describing whether video playback prevents display and
    ///     device sleep.
    ///   - navigationMode: The mode used when navigating between items of the playback queue.
    ///   - backwardSkipInterval: The backward skip interval, in seconds. Must be greater than zero.
    ///   - forwardSkipInterval: The forward skip interval, in seconds. Must be greater than zero.
    ///   - allowsConstrainedNetworkAccess: A Boolean describing whether the player is permitted to play content on
    ///     networks with Low Data Mode enabled.
    public init(
        allowsExternalPlayback: Bool = true,
        usesExternalPlaybackWhileMirroring: Bool = false,
        preventsDisplaySleepDuringVideoPlayback: Bool = true,
        navigationMode: NavigationMode = .smart(interval: 3),
        backwardSkipInterval: TimeInterval = 10,
        forwardSkipInterval: TimeInterval = 10,
        allowsConstrainedNetworkAccess: Bool = true
    ) {
        assert(backwardSkipInterval > 0)
        assert(forwardSkipInterval > 0)
        self.allowsExternalPlayback = allowsExternalPlayback
        self.usesExternalPlaybackWhileMirroring = usesExternalPlaybackWhileMirroring
        self.preventsDisplaySleepDuringVideoPlayback = preventsDisplaySleepDuringVideoPlayback
        self.navigationMode = navigationMode
        self.backwardSkipInterval = backwardSkipInterval
        self.forwardSkipInterval = forwardSkipInterval
        self.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
    }

    /// Returns the skip interval for some direction.
    ///
    /// - Parameter skip: The skip direction.
    /// - Returns: The interval, in seconds.
    public func interval(forSkip skip: Skip) -> TimeInterval {
        switch skip {
        case .backward:
            return backwardSkipInterval
        case .forward:
            return forwardSkipInterval
        }
    }
}
