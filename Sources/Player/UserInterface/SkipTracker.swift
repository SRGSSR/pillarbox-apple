//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore
import SwiftUI

/// An observable object that manages skip interactions.
///
/// A skip tracker is an [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
/// designed to handle multi-tap gestures for skipping forward and backward in content played by a ``Player``.
///
/// These gestures, popularized by apps like YouTube, provide a fast and intuitive way for users to navigate through content
/// by tapping multiple times to skip in the desired direction.
///
/// This tracker does not dictate how the multi-tap gesture itself is implemented. Instead, it provides an abstraction
/// for managing rapid user interactions. When multiple skip requests occur within a short time interval, the tracker:
///
/// - Triggers a skip in the most recently requested direction.
/// - Performs additional skips for each subsequent request within the same interval.
///
/// ### Key benefits
///
/// This implementation optimizes the user experience:
///
/// - Once fast skipping is triggered, every additional request performs a skip, regardless of direction. This ensures
///   intuitive navigation, allowing users to move forward and backward effortlessly.
/// - A request typically corresponds to a single interaction (e.g. a tap), avoiding the need for explicit multi-tap
///   gestures that could introduce delays in single-tap interactions.
///
/// ## Usage
///
/// A skip tracker is used as follows:
///
/// 1. Instantiate a `SkipTracker` within your view hierarchy.
/// 2. Bind it to a ``Player`` instance using the ``SwiftUICore/View/bind(_:to:)-kb3n`` modifier.
/// 3. Attach a single-tap interaction (e.g. [TapGesture](https://developer.apple.com/documentation/swiftui/tapgesture)
///    or [SpatialTapGesture](https://developer.apple.com/documentation/swiftui/spatialtapgesture)) to request a skip
///    backward (``SkipTracker/requestSkipBackward()``) or forward (``SkipTracker/requestSkipForward()``).
/// 4. Use ``SkipTracker/state-swift.property`` to update the UI dynamically when fast seeking is active, such as displaying lightweight
///    overlays indicating the skip direction and total accumulated skip interval.
///
/// > Note: For step-by-step integration instructions have a look at the associated <doc:supporting-skip-gestures> tutorial.
@available(iOS 16, *)
@available(tvOS, unavailable)
public final class SkipTracker: ObservableObject {
    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` in SwiftUI code.
    public var player: Player? {
        didSet {
            guard player != oldValue else { return }
            counter = nil
        }
    }

    /// The tracker state.
    public var state: State {
        Self.state(counter: counter, minimumCount: minimumCount, player: player)
    }

    /// A Boolean that describes whether skipping is taking place.
    public var isSkipping: Bool {
        state.isSkipping
    }

    private let minimumCount: Int
    private let trigger = Trigger()

    @Published private var counter: Counter?

    /// Create a tracker managing skips.
    ///
    /// - Parameters:
    ///   - count: The number of requests required to enable skipping.
    ///   - delay: The delay after which skipping is disabled.
    public init(count: Int = 2, delay: TimeInterval = 0.4) {
        // swiftlint:disable:next empty_count
        assert(count > 0 && delay > 0)
        minimumCount = count
        configureIdlePublisher(delay: delay)
    }

    /// Requests a skip backward.
    ///
    /// - Returns: `true` iff the request could be fulfilled.
    @discardableResult
    public func requestSkipBackward() -> Bool {
        requestSkip(.backward)
    }

    /// Requests a skip forward.
    ///
    /// - Returns: `true` iff the request could be fulfilled.
    @discardableResult
    public func requestSkipForward() -> Bool {
        requestSkip(.forward)
    }

    /// Request a skip in a given direction.
    ///
    /// - Parameter skip: The skip direction.
    /// - Returns: `true` iff the request could be fulfilled.
    @discardableResult
    public func requestSkip(_ skip: Skip) -> Bool {
        guard let player, player.canSkip(skip) else { return false }
        counter = updateCounter(counter, with: skip)
        reset()
        guard Self.state(counter: counter, minimumCount: minimumCount, player: player).isSkipping else { return false }
        player.skip(skip)
        return true
    }

    private func configureIdlePublisher(delay: TimeInterval) {
        trigger.signal(activatedBy: TriggerId.reset)
            .map { _ in
                Timer.publish(every: delay, on: .main, in: .common)
                    .autoconnect()
                    .first()
            }
            .switchToLatest()
            .map { _ in nil }
            .assign(to: &$counter)
    }

    private func updateCounter(_ counter: Counter?, with skip: Skip) -> Counter {
        guard let counter else {
            return .init(skip: skip, value: 1)
        }
        if skip == counter.skip {
            return .init(skip: skip, value: counter.value + 1)
        }
        else if counter.value >= minimumCount {
            return .init(skip: skip, value: minimumCount)
        }
        else {
            return .init(skip: skip, value: 1)
        }
    }

    private func reset() {
        trigger.activate(for: TriggerId.reset)
    }
}

public extension SkipTracker {
    /// The current tracker state.
    enum State: Equatable {
        /// Inactive.
        case inactive

        /// Skipping backward.
        ///
        /// The total accumulated interval in seconds is provided as associated value.
        case skippingBackward(TimeInterval)

        /// Skipping forward.
        ///
        /// The total accumulated interval in seconds is provided as associated value.
        case skippingForward(TimeInterval)

        var isSkipping: Bool {
            self != .inactive
        }
    }

    private static func state(counter: Counter?, minimumCount: Int, player: Player?) -> State {
        guard let player, let counter, counter.value >= minimumCount else { return .inactive }
        let count = counter.value - minimumCount + 1
        switch counter.skip {
        case .backward:
            return .skippingBackward(Double(count) * player.configuration.backwardSkipInterval)
        case .forward:
            return .skippingForward(Double(count) * player.configuration.forwardSkipInterval)
        }
    }
}

private extension SkipTracker {
    struct Counter: Equatable {
        let skip: Skip
        let value: Int
    }

    enum TriggerId {
        case reset
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
