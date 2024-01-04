//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import SwiftUI

/// An observable object tracking playback progress.
///
/// A progress tracker is an [ObservableObject](https://developer.apple.com/documentation/combine/observableobject) 
/// used to read and update the progress of an associated ``Player``. It automatically provides current progress
/// information as well as the available range for its values. It also ensures that interactive progress updates
/// do not conflict with reported progress updates, ensuring a smooth user experience.
///
/// > Warning: Progress trackers should be associated with local view scopes to avoid unnecessary view body refreshes. 
/// Please refer to <doc:state-observation> for more information.
///
/// ## Usage
///
/// A progress tracker is used as follows:
///
/// 1. Instantiate a `ProgressTracker` in your view hierarchy, setting up the refresh interval you need. You should
///    instantiate a progress tracker in the narrowest possible view scope so that refreshes only affect a small
///    portion of your view hierarchy, especially if the applied refresh interval is small.
/// 2. Bind the progress tracker to a ``Player`` instance by applying the ``SwiftUI/View/bind(_:to:)-8fqem`` modifier.
/// 3. The current progress can be retrieved from the ``progress`` property and displayed in any way you want. Use
///    the ``range`` property to determine the currently available range, and ``isProgressAvailable`` to know whether
///    progress should actually be displayed.
/// 4. The current progress can be updated by mutating the ``progress`` property. Be sure to set the ``isInteracting``
///    property to `true` while progress is updated interactively so that changes take precedence over reported values
///    during the interaction.
///
/// The PillarboxPlayer framework also provides automatic progress interaction integration with the SwiftUI standard
/// slider, see ``SwiftUI/Slider/init(progressTracker:label:minimumValueLabel:maximumValueLabel:onEditingChanged:)``.
///
/// > Note: For step-by-step integration instructions have a look at the associated <doc:tracking-progress> tutorial.
public final class ProgressTracker: ObservableObject {
    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player? {
        willSet {
            resumePlaybackIfNeeded(with: player)
        }
        didSet {
            guard isInteracting else { return }
            pausePlaybackIfNeeded(with: player)
        }
    }

    /// A Boolean describing whether user interaction is currently changing the progress value.
    @Published public var isInteracting = false {
        willSet {
            if newValue {
                pausePlaybackIfNeeded(with: player)
            }
            else {
                resumePlaybackIfNeeded(with: player)
                seek(to: progress, optimal: false)
            }
        }
    }

    @Published private var _progress: Float?

    private let seekBehavior: SeekBehavior
    private var wasPaused = false

    /// The current progress.
    ///
    /// Returns a value between 0 and 1. The progress might be different from the actual player progress during
    /// user interaction.
    ///
    /// This property returns 0 when no progress information is available. Use `isProgressAvailable` to check whether
    /// progress is available or not.
    public var progress: Float {
        get {
            _progress ?? 0
        }
        set {
            guard _progress != nil else { return }
            _progress = newValue.clamped(to: range)
            guard seekBehavior == .immediate else { return }
            seek(to: newValue, optimal: true)
        }
    }

    /// The time corresponding to the current progress.
    ///
    /// The returned value might be different from the player current time when interaction takes place.
    ///
    /// Non-`nil` returned times are guaranteed to be valid.
    public var time: CMTime? {
        time(forProgress: _progress)
    }

    /// The allowed range for progress values.
    public var range: ClosedRange<Float> {
        _progress != nil ? 0...1 : 0...0
    }

    /// A Boolean reporting whether progress information is available.
    ///
    /// This Boolean is a recommendation you can use to entirely hide progress information in cases where it is not
    /// meaningful (e.g. when loading content or for livestreams).
    public var isProgressAvailable: Bool {
        _progress != nil
    }

    /// The current time range.
    ///
    /// Non-`nil` returned ranges are guaranteed to be valid.
    public var timeRange: CMTimeRange? {
        guard let timeRange = player?.seekableTimeRange, timeRange.isValidAndNotEmpty else { return nil }
        return timeRange
    }

    /// Creates a progress tracker updating its progress at the specified interval.
    /// 
    /// - Parameter interval: The interval at which progress must be updated.
    public init(interval: CMTime, seekBehavior: SeekBehavior = .immediate) {
        self.seekBehavior = seekBehavior
        $player
            .removeDuplicates()
            .map { [$isInteracting] player -> AnyPublisher<Float?, Never> in
                guard let player else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return Publishers.CombineLatest(
                    Self.currentTimePublisher(for: player, interval: interval, isInteracting: $isInteracting),
                    player.propertiesPublisher.slice(at: \.seekableTimeRange)
                )
                .map { time, seekableTimeRange in
                    Self.progress(for: time, in: seekableTimeRange)
                }
                .prepend(Self.progress(for: player.time, in: player.seekableTimeRange))
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .receiveOnMainThread()
            .assign(to: &$_progress)
    }

    private static func currentTimePublisher(
        for player: Player,
        interval: CMTime,
        isInteracting: Published<Bool>.Publisher
    ) -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest(
            player.queuePlayer.smoothCurrentTimePublisher(interval: interval, queue: .main),
            isInteracting
        )
        .compactMap { time, isInteracting in
            !isInteracting ? time : nil
        }
        .eraseToAnyPublisher()
    }

    private static func progress(for time: CMTime, in timeRange: CMTimeRange) -> Float? {
        guard time.isValid, timeRange.isValidAndNotEmpty else { return nil }
        return Float((time - timeRange.start).seconds / timeRange.duration.seconds).clamped(to: 0...1)
    }

    private func seek(to progress: Float, optimal: Bool) {
        guard let player, let time = time(forProgress: progress) else { return }
        if optimal {
            player.seek(to: time)
        }
        else {
            player.seek(near(time), smooth: false)
        }
    }

    private func time(forProgress progress: Float?) -> CMTime? {
        guard let timeRange, let progress else { return nil }
        return timeRange.start + CMTimeMultiplyByFloat64(timeRange.duration, multiplier: Float64(progress))
    }

    private func pausePlaybackIfNeeded(with player: Player?) {
        guard let player, player.playbackState == .playing, seekBehavior == .immediate else { return }
        player.pause()
        wasPaused = true
    }

    private func resumePlaybackIfNeeded(with player: Player?) {
        guard let player, wasPaused else { return }
        player.play()
        wasPaused = false
    }
}

public extension View {
    /// Binds a progress tracker to a player.
    ///
    /// - Parameters:
    ///   - progressTracker: The progress tracker to bind.
    ///   - player: The player to observe.
    func bind(_ progressTracker: ProgressTracker, to player: Player?) -> some View {
        onAppear {
            progressTracker.player = player
        }
        .onChange(of: player) { newValue in
            progressTracker.player = newValue
        }
    }
}
