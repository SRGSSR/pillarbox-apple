//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Core
import Foundation
import SwiftUI
import UIKit

/// An observable object tracking user interface visibility.
///
/// The tracker automatically turns off visibility after a delay while playing content. It also automatically turns
/// on visibility when playback is paused externally (e.g. by another app or through the control center).
@available(tvOS, unavailable)
public final class VisibilityTracker: ObservableObject {
    private enum TriggerId {
        case reset
    }

    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?

    /// Returns whether the user interface should be hidden.
    @Published public private(set) var isUserInterfaceHidden: Bool

    private let delay: TimeInterval
    private let trigger = Trigger()
    private let togglePublisher = PassthroughSubject<Bool, Never>()

    /// Creates a tracker managing user interface visibility.
    /// 
    /// - Parameters:
    ///   - delay: The delay after which `isUserInterfaceHidden` is automatically reset to `true`.
    ///   - isUserInterfaceHidden: The initial value for `isUserInterfaceHidden`.
    public init(delay: TimeInterval = 3, isUserInterfaceHidden: Bool = false) {
        assert(delay > 0)

        self.delay = delay
        self.isUserInterfaceHidden = isUserInterfaceHidden

        $player
            .removeDuplicates()
            .map { player -> AnyPublisher<PlaybackState, Never> in
                guard let player else {
                    return Empty().eraseToAnyPublisher()
                }
                return player.$playbackState.eraseToAnyPublisher()
            }
            .switchToLatest()
            .compactMap { [weak self] playbackState in
                self?.updatePublisher(for: playbackState)
            }
            .switchToLatest()
            .removeDuplicates()
            .receiveOnMainThread()
            .assign(to: &$isUserInterfaceHidden)
    }

    /// Toggles user interface visibility.
    public func toggle() {
        togglePublisher.send(!isUserInterfaceHidden)
    }

    /// Resets user interface auto hide delay.
    public func reset() {
        guard !isUserInterfaceHidden else { return }
        trigger.activate(for: TriggerId.reset)
    }

    private func updatePublisher(for playbackState: PlaybackState) -> AnyPublisher<Bool, Never> {
        switch playbackState {
        case .playing:
            return togglePublisher
                .prepend(isUserInterfaceHidden)
                .compactMap { [weak self] isHidden -> AnyPublisher<Bool, Never>? in
                    guard let self else { return nil }
                    return Just(isHidden)
                        .append(autoHidePublisher(delay: delay), if: !isHidden)
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        case .paused:
            return Publishers.Merge(togglePublisher, foregroundPublisher())
                .prepend(false)
                .eraseToAnyPublisher()
        default:
            return Publishers.Merge(togglePublisher, foregroundPublisher())
                .prepend(isUserInterfaceHidden)
                .eraseToAnyPublisher()
        }
    }

    private func foregroundPublisher() -> AnyPublisher<Bool, Never> {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .map { _ in false }
            .eraseToAnyPublisher()
    }

    private func autoHidePublisher(delay: TimeInterval) -> AnyPublisher<Bool, Never> {
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reset)) {
            Timer.publish(every: delay, on: .main, in: .common)
                .autoconnect()
                .first()
        }
        .map { _ in true }
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

private extension Publisher {
    func append<P>(
        _ publisher: P,
        if condition: Bool
    ) -> AnyPublisher<Output, Failure> where P: Publisher, Failure == P.Failure, Output == P.Output {
        if condition {
            return self.append(publisher).eraseToAnyPublisher()
        }
        else {
            return self.eraseToAnyPublisher()
        }
    }
}
