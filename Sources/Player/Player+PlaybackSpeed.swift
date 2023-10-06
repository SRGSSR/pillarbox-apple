//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import SwiftUI

public extension Player {
    /// The currently applicable playback speed.
    var effectivePlaybackSpeed: Float {
        _playbackSpeed.effectiveValue
    }

    /// The currently allowed playback speed range.
    var playbackSpeedRange: ClosedRange<Float> {
        _playbackSpeed.effectiveRange
    }

    /// A binding to read and write the current playback speed.
    var playbackSpeed: Binding<Float> {
        .init {
            self.effectivePlaybackSpeed
        } set: { newValue in
            self.setDesiredPlaybackSpeed(newValue)
        }
    }

    /// Sets the desired playback speed.
    ///
    /// - Parameter playbackSpeed: The playback speed.
    ///
    /// This value might not be applied immediately or might not be applicable at all. You must check
    /// `effectivePlaybackSpeed` to obtain the actually applied speed.
    func setDesiredPlaybackSpeed(_ playbackSpeed: Float) {
        desiredPlaybackSpeedPublisher.send(playbackSpeed)
    }
}

extension Player {
    func playbackSpeedUpdatePublisher() -> AnyPublisher<PlaybackSpeedUpdate, Never> {
        Publishers.Merge3(
            desiredPlaybackSpeedUpdatePublisher(),
            supportedPlaybackSpeedPublisher(),
            avPlayerViewControllerPlaybackSpeedUpdatePublisher()
        )
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func desiredPlaybackSpeedUpdatePublisher() -> AnyPublisher<PlaybackSpeedUpdate, Never> {
        desiredPlaybackSpeedPublisher
            .map { .value($0) }
            .eraseToAnyPublisher()
    }
}

private extension Player {
    static func playbackSpeedRange(for timeRange: CMTimeRange, duration: CMTime, time: CMTime) -> ClosedRange<Float>? {
        let streamType = StreamType(for: timeRange, duration: duration)
        switch streamType {
        case .live:
            return 1...1
        case .dvr where time > timeRange.end - CMTime(value: 5, timescale: 1):
            return 0.1...1
        case .unknown:
            return nil
        default:
            return 0.1...2
        }
    }

    func supportedPlaybackSpeedPublisher() -> AnyPublisher<PlaybackSpeedUpdate, Never> {
        Publishers.CombineLatest(
            propertiesPublisher,
            periodicTimePublisher(forInterval: CMTime(value: 1, timescale: 1))
        )
        .compactMap { properties, time in
            guard !properties.isEmpty else { return .range(nil) }
            guard let range = Self.playbackSpeedRange(
                for: properties.seekableTimeRange,
                duration: properties.duration,
                time: time
            ) else {
                return nil
            }
            return .range(range)
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    // Publishes speed updates triggered from `AVPlayerViewController`. Not necessary on tvOS since the standard UI
    // does not provide speed controls.
    func avPlayerViewControllerPlaybackSpeedUpdatePublisher() -> AnyPublisher<PlaybackSpeedUpdate, Never> {
#if os(iOS)
        queuePlayer.publisher(for: \.rate)
            .filter { rate in
                rate != 0 && Thread.callStackSymbols.contains { symbol in
                    symbol.contains("AVPlayerController")
                }
            }
            .removeDuplicates()
            .map { .value($0) }
            .eraseToAnyPublisher()
#else
        Empty(completeImmediately: true)
            .eraseToAnyPublisher()
#endif
    }
}
