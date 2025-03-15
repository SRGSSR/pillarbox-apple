//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore
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
    public var state: State {
        guard let player else { return .idle }
        switch request {
        case let .backward(requestCount):
            guard let interval = Self.skipInterval(
                forRequestCount: requestCount,
                count: count,
                interval: player.configuration.backwardSkipInterval
            ) else {
                return .idle
            }
            return .skippingBackward(interval)
        case let .forward(requestCount):
            guard let interval = Self.skipInterval(
                forRequestCount: requestCount,
                count: count,
                interval: player.configuration.forwardSkipInterval
            ) else {
                return .idle
            }
            return .skippingForward(interval)
        }
    }

    private let count: Int
    private let trigger = Trigger()

    @Published private var request: Request = .none

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

    private static func canRequest(_ skip: Skip, for player: Player) -> Bool {
        switch skip {
        case .backward:
            return player.canSkipBackward()
        case .forward:
            return player.canSkipForward()
        }
    }

    private static func skipInterval(forRequestCount requestCount: Int, count: Int, interval: TimeInterval) -> TimeInterval? {
        guard requestCount >= count else { return nil }
        return Double(requestCount - count + 1) * interval
    }

    /// Request a skip in a given direction.
    ///
    /// - Parameter skip: The skip direction.
    @discardableResult
    public func requestSkip(_ skip: Skip) -> Bool {
        guard let player, Self.canRequest(skip, for: player) else { return false }
        request = update(request: request, with: skip)
        reset()
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
            .map { _ in .none }
            .assign(to: &$request)
    }

    private func update(request: Request, with skip: Skip) -> Request {
        switch (request, skip) {
        case let (.backward(requestCount), .backward):
            return .backward(requestCount + 1)
        case let (.forward(requestCount), .forward):
            return .forward(requestCount + 1)
        case let (.backward(requestCount), .forward):
            return .forward(requestCount >= count ? count : 1)
        case let (.forward(requestCount), .backward):
            return .backward(requestCount >= count ? count : 1)
        }
    }

    private func reset() {
        trigger.activate(for: TriggerId.reset)
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

private extension SkipTracker {
    enum Request {
        case backward(Int)
        case forward(Int)

        static var none: Self {
            .backward(0)
        }
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
