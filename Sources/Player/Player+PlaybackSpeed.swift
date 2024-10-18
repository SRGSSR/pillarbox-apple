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
    /// - Parameter playbackSpeed: The playback speed. The default value is 1.
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
            defaultRateSpeedUpdatePublisher()
        )
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func playbackSpeedPublisher() -> AnyPublisher<PlaybackSpeed, Never> {
        playbackSpeedUpdatePublisher()
            .scan(.indefinite) { speed, update in
                speed.updated(with: update)
            }
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
    private static func playbackSpeedUpdate(for properties: PlayerProperties, at time: CMTime) -> PlaybackSpeedUpdate? {
        guard !properties.isEmpty else { return .range(nil) }
        switch properties.streamType {
        case .live:
            return .range(1...1)
        case .dvr where time > properties.seekableTimeRange.end - CMTime(value: 5, timescale: 1):
            return .range(0.1...1)
        case .unknown:
            // Updates must be suspended while the stream type is unknown
            return nil
        default:
            return .range(0.1...2)
        }
    }

    func supportedPlaybackSpeedPublisher() -> AnyPublisher<PlaybackSpeedUpdate, Never> {
        Publishers.CombineLatest(
            propertiesPublisher,
            periodicTimePublisher(forInterval: CMTime(value: 1, timescale: 1))
        )
        .compactMap { Self.playbackSpeedUpdate(for: $0, at: $1) }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func defaultRateSpeedUpdatePublisher() -> AnyPublisher<PlaybackSpeedUpdate, Never> {
        queuePlayer.publisher(for: \.defaultRate)
            .removeDuplicates()
            .map { .value($0) }
            .eraseToAnyPublisher()
    }
}
