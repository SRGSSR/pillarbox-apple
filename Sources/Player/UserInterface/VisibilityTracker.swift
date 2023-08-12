//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Core
import Foundation
import SwiftUI

/// An observable object tracking user interface visibility.
///
/// The tracker automatically turns off visibility after a delay while playing content.
@available(tvOS, unavailable)
public final class VisibilityTracker: ObservableObject {
    private enum TriggerId {
        case toggle
        case reset
    }

    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?

    /// Returns whether the user interface should be hidden.
    @Published public private(set) var isUserInterfaceHidden: Bool {
        didSet {
            guard !isUserInterfaceHidden else { return }
            trigger.activate(for: TriggerId.reset)
        }
    }

    private let trigger = Trigger()

    /// Creates a tracker managing user interface visibility.
    /// 
    /// - Parameters:
    ///   - delay: The delay after which `isUserInterfaceHidden` is automatically reset to `true`.
    ///   - isUserInterfaceHidden: The initial value for `isUserInterfaceHidden`.
    public init(delay: TimeInterval = 3, isUserInterfaceHidden: Bool = false) {
        assert(delay > 0)
        self.isUserInterfaceHidden = isUserInterfaceHidden

        Publishers.Merge(
            togglePublisher(),
            autohidePublisher(delay: delay)
        )
        .receiveOnMainThread()
        .assign(to: &$isUserInterfaceHidden)
    }

    /// Toggles user interface visibility.
    public func toggle() {
        trigger.activate(for: TriggerId.toggle)
    }

    /// Resets user interface auto hide delay.
    public func reset() {
        guard !isUserInterfaceHidden else { return }
        trigger.activate(for: TriggerId.reset)
    }

    private func togglePublisher() -> AnyPublisher<Bool, Never> {
        trigger.signal(activatedBy: TriggerId.toggle)
            .weakCapture(self, at: \.isUserInterfaceHidden)
            .map { !$1 }
            .eraseToAnyPublisher()
    }

    private func autohidePublisher(delay: TimeInterval) -> AnyPublisher<Bool, Never> {
        $player
            .removeDuplicates()
            .map { player -> AnyPublisher<PlaybackState, Never> in
                guard let player else {
                    return Empty().eraseToAnyPublisher()
                }
                return player.$playbackState.eraseToAnyPublisher()
            }
            .switchToLatest()
            .map { [trigger] playbackState -> AnyPublisher<Bool, Never> in
                guard playbackState == .playing else {
                    return Empty().eraseToAnyPublisher()
                }
                return Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reset)) {
                    Timer.publish(every: delay, on: .main, in: .common)
                        .autoconnect()
                        .first()
                }
                .map { _ in true }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

@available(tvOS, unavailable)
public extension View {
    /// Binds a visibility tracker to a player.
    /// 
    /// - Parameters:
    ///   - visibilityTracker: The visibility tracker to bind.
    ///   - player: The player to observe.
    func bind(_ visibilityTracker: VisibilityTracker, to player: Player?) -> some View {
        onAppear {
            visibilityTracker.player = player
        }
        .onChange(of: player) { newValue in
            visibilityTracker.player = newValue
        }
    }
}
