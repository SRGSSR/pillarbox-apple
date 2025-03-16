//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore
import SwiftUI

/// An observable object managing skips.
@available(iOS 16, *)
@available(tvOS, unavailable)
public final class SkipTracker: ObservableObject {
    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` in SwiftUI code.
    public var player: Player? {
        didSet {
            guard player != oldValue else { return }
            state = nil
        }
    }

    /// The current active state, if any.
    public var activeState: State? {
        activeState(from: state)
    }

    /// A Boolean that describes whether skipping is currently active.
    public var isActive: Bool {
        activeState != nil
    }

    private let count: Int
    private let trigger = Trigger()

    @Published private var state: State?

    /// Create a tracker managing skips.
    ///
    /// - Parameters:
    ///   - count: The required number of requests which to be made to enable skip mode.
    ///   - delay: The delay after which skip mode is disabled.
    public init(count: Int = 2, delay: TimeInterval = 0.4) {
        // swiftlint:disable:next empty_count
        assert(count > 0 && delay > 0)
        self.count = count
        configureIdlePublisher(delay: delay)
    }

    private func activeState(from requestState: State?) -> State? {
        guard let requestState, requestState.count >= count else { return nil }
        return .init(skip: requestState.skip, count: requestState.count - count + 1)
    }

    /// Request a skip in a given direction.
    ///
    /// - Parameter skip: The skip direction.
    /// - Returns: `true` iff the request could be fulfilled.
    @discardableResult
    public func requestSkip(_ skip: Skip) -> Bool {
        guard let player, player.canSkip(skip) else { return false }
        state = update(state: state, with: skip)
        reset()

        guard let activeState = activeState(from: state) else { return false }
        player.skip(activeState.skip)
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
            .assign(to: &$state)
    }

    private func update(state: State?, with skip: Skip) -> State {
        guard let state else {
            return .init(skip: skip, count: 1)
        }
        if skip == state.skip {
            return .init(skip: skip, count: state.count + 1)
        }
        else if state.count >= count {
            return .init(skip: skip, count: count)
        }
        else {
            return .init(skip: skip, count: 1)
        }
    }

    private func reset() {
        trigger.activate(for: TriggerId.reset)
    }
}

public extension SkipTracker {
    /// The state of skip tracking.
    struct State: Equatable {
        /// The current skip direction.
        public let skip: Skip

        /// The number of requests in the skip direction.
        public let count: Int
    }
}

private extension SkipTracker {
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
