//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia

extension Player {
    /// The currently applicable playback speed.
    public var effectivePlaybackSpeed: Float {
        _playbackSpeed.effectiveValue
    }

    /// The currently allowed playback speed range.
    public var playbackSpeedRange: ClosedRange<Float> {
        _playbackSpeed.effectiveRange
    }

    private static func playbackSpeedRange(for timeRange: CMTimeRange, itemDuration: CMTime, time: CMTime) -> ClosedRange<Float>? {
        let streamType = StreamType(for: timeRange, itemDuration: itemDuration)
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

    /// Set the desired playback speed. This value might not be applied immediately or might not be applicable at all,
    /// check `effectivePlaybackSpeed` for the actually applied speed.
    /// - Parameter playbackSpeed: The playback speed.
    public func setDesiredPlaybackSpeed(_ playbackSpeed: Float) {
        desiredPlaybackSpeedPublisher.send(playbackSpeed)
    }

    func configurePlaybackSpeedPublisher() {
        playbackSpeedUpdatePublisher()
            .scan(.indefinite) { speed, update in
                speed.updated(with: update)
            }
            .removeDuplicates()
            .receiveOnMainThread()
            .assign(to: &$_playbackSpeed)

        $_playbackSpeed
            .sink { [queuePlayer] speed in
                guard queuePlayer.rate != 0 else { return }
                queuePlayer.rate = speed.effectiveValue
            }
            .store(in: &cancellables)
    }

    private func playbackSpeedUpdatePublisher() -> AnyPublisher<PlaybackSpeedUpdate, Never> {
        Publishers.Merge3(
            desiredPlaybackSpeedUpdatePublisher(),
            supportedPlaybackSpeedPublisher(),
            avPlayerViewControllerPlaybackSpeedUpdatePublisher()
        )
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    private func desiredPlaybackSpeedUpdatePublisher() -> AnyPublisher<PlaybackSpeedUpdate, Never> {
        desiredPlaybackSpeedPublisher
            .removeDuplicates()
            .map { .value($0) }
            .eraseToAnyPublisher()
    }

    private func supportedPlaybackSpeedPublisher() -> AnyPublisher<PlaybackSpeedUpdate, Never> {
        queuePlayer.publisher(for: \.currentItem)
            .weakCapture(self)
            .map { item, player -> AnyPublisher<PlaybackSpeedUpdate, Never> in
                if let item {
                    return Publishers.CombineLatest3(
                        item.timeRangePublisher(),
                        item.durationPublisher(),
                        player.periodicTimePublisher(forInterval: CMTime(value: 1, timescale: 1))
                    )
                    .compactMap { timeRange, itemDuration, time in
                        guard let range = Self.playbackSpeedRange(for: timeRange, itemDuration: itemDuration, time: time) else { return nil }
                        return .range(range)
                    }
                    .eraseToAnyPublisher()
                }
                else {
                    return Just(.range(nil))
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // Publish speed updates triggered from `AVPlayerViewController`. Not necessary on tvOS since the standard UI
    // does not provide speed controls.
    private func avPlayerViewControllerPlaybackSpeedUpdatePublisher() -> AnyPublisher<PlaybackSpeedUpdate, Never> {
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
