//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Core
import Foundation
import SwiftUI

/// Tracks user interface visibility.
@available(tvOS, unavailable)
public final class VisibilityTracker: ObservableObject {
    private enum TriggerId {
        case reload
    }

    /// The player to attach. Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?

    /// Returns whether the user interface should be hidden.
    @Published public private(set) var isUserInterfaceHidden: Bool {
        didSet {
            guard !isUserInterfaceHidden else { return }
            trigger.activate(for: TriggerId.reload)
        }
    }

    private let trigger = Trigger()

    /// Create a tracker managing user interface visibility and automatically setting visibility to hidden after
    /// some timeout.
    /// - Parameters:
    ///   - timeout: The timeout after which `isUserInterfaceHidden` is automatically reset to `true`.
    ///   - isUserInterfaceHidden: The initial value for `isUserInterfaceHidden`.
    public init(timeout: TimeInterval = 4, isUserInterfaceHidden: Bool = false) {
        self.isUserInterfaceHidden = isUserInterfaceHidden

        $player
            .map { player -> AnyPublisher<PlaybackState, Never> in
                guard let player else {
                    return Empty<PlaybackState, Never>().eraseToAnyPublisher()
                }
                return player.$playbackState.eraseToAnyPublisher()
            }
            .switchToLatest()
            .map { [trigger] playbackState -> AnyPublisher<Bool, Never> in
                guard playbackState == .playing else {
                    return Empty<Bool, Never>().eraseToAnyPublisher()
                }
                return Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) {
                    Timer.publish(every: timeout, on: .main, in: .common)
                        .autoconnect()
                        .first()
                }
                .map { _ in true }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$isUserInterfaceHidden)
    }

    /// Toggle user interface visibility.
    public func toggle() {
        isUserInterfaceHidden.toggle()
    }

    /// Reset user interface visibility timeout.
    public func reset() {
        if !isUserInterfaceHidden {
            trigger.activate(for: TriggerId.reload)
        }
    }
}

@available(tvOS, unavailable)
public extension View {
    /// Bind a visibility tracker to a player.
    /// - Parameters:
    ///   - visibilityTracker: The visibility tracker to bind.
    ///   - player: The player to observe.
    func bind(_ visibility: VisibilityTracker, to player: Player?) -> some View {
        onAppear {
            visibility.player = player
        }
        .onChange(of: player) { newValue in
            visibility.player = newValue
        }
    }
}
