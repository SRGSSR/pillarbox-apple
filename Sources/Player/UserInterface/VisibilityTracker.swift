//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore
import SwiftUI
import UIKit

/// An observable object tracking user interface visibility.
///
/// A visibility tracker is an [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
/// used to manage playback control visibility. It provides several standard behaviors that are usually expected from
/// player user interfaces:
///
/// - Users should be able to toggle user interface visibility on or off with some kind of interaction (e.g., tapping
///   the player interface itself).
/// - The user interface must automatically hide after some delay when the player is actually playing content (except
///   when VoiceOver has been enabled).
/// - The user interface must be automatically revealed when playback is paused externally (e.g., by another app or
///   through the Control Center) so that playback can be quickly resumed.
///
/// ## Usage
///
/// A visibility tracker is used as follows:
///
/// 1. Instantiate a ``VisibilityTracker`` in your view hierarchy. You can setup the initial visibility status as well
///    as the delay after which controls must be automatically hidden during playback.
/// 2. Bind the visibility tracker to a ``Player`` instance by applying the ``SwiftUICore/View/bind(_:to:)-wthx`` modifier.
/// 3. Use ``isUserInterfaceHidden`` to adjust visibility of your user interface components based on the current
///    visibility tracker recommendation.
/// 4. Introduce an interaction (e.g., a tap gesture) that lets your users toggle user interface visibility on or off.
///    Simply call ``toggle()`` from the action associated with this interaction.
/// 5. Call ``reset()`` when a user interaction should prevent the user interface from being automatically hidden. You
///    can for example call this method during slider interactions so that the user interface stays visible while the
///    user is still moving the slider.
///
/// > Note: For step-by-step integration instructions have a look at the associated <doc:tracking-visibility> tutorial.
@available(iOS 16, *)
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
                return player.propertiesPublisher
                    .slice(at: \.playbackState)
                    .eraseToAnyPublisher()
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
            return Publishers.CombineLatest(
                userInterfaceHiddenPublisher()
                    .prepend(isUserInterfaceHidden),
                voiceOverRunningPublisher()
            )
            .compactMap { [weak self] isHidden, isVoiceOverRunning -> AnyPublisher<Bool, Never>? in
                guard let self else { return nil }
                return Just(isHidden)
                    .append(autoHidePublisher(delay: delay), if: !isHidden && !isVoiceOverRunning)
            }
            .switchToLatest()
            .eraseToAnyPublisher()
        case .paused:
            return Publishers.Merge(userInterfaceHiddenPublisher(), foregroundPublisher())
                .prepend(false)
                .eraseToAnyPublisher()
        default:
            return Publishers.Merge(userInterfaceHiddenPublisher(), foregroundPublisher())
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

    private func userInterfaceHiddenPublisher() -> AnyPublisher<Bool, Never> {
        Publishers.Merge(togglePublisher, voiceOverUnhidePublisher())
            .eraseToAnyPublisher()
    }

   private func voiceOverStatusPublisher() -> AnyPublisher<Bool, Never> {
        NotificationCenter.default.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification)
            .map { _ in UIAccessibility.isVoiceOverRunning }
            .eraseToAnyPublisher()
    }

    private func voiceOverRunningPublisher() -> AnyPublisher<Bool, Never> {
        voiceOverStatusPublisher()
            .prepend(UIAccessibility.isVoiceOverRunning)
            .eraseToAnyPublisher()
    }

    private func voiceOverUnhidePublisher() -> AnyPublisher<Bool, Never> {
        voiceOverStatusPublisher()
            .filter { $0 }
            .map { _ in false }
            .eraseToAnyPublisher()
    }
}

@available(iOS 16, *)
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
