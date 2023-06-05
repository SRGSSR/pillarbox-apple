//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import ComScore
import CoreMedia
import Foundation
import Player

/// Stream tracker for comScore. Implements streaming measurements according to Mediapulse official specifications.
public final class ComScoreTracker: PlayerItemTracker {
    private var streamingAnalytics = SCORStreamingAnalytics()
    private var cancellables = Set<AnyCancellable>()
    @Published private var metadata: Metadata = .empty

    public init(configuration: Void, metadataPublisher: AnyPublisher<Metadata, Never>) {
        metadataPublisher.assign(to: &$metadata)
    }

    public func enable(for player: Player) {
        streamingAnalytics.createPlaybackSession()
        streamingAnalytics.setMediaPlayerName("Pillarbox")
        streamingAnalytics.setMediaPlayerVersion(PackageInfo.version)

        $metadata.sink { [weak self] metadata in
            self?.updateMetadata(with: metadata)
        }
        .store(in: &cancellables)

        Publishers.CombineLatest3(player.$playbackState, player.$isSeeking, player.$isBuffering)
            .weakCapture(player)
            .sink { [weak self] state, player in
                self?.notify(playbackState: state.0, isSeeking: state.1, isBuffering: state.2, player: player)
            }
            .store(in: &cancellables)

        player.objectWillChange
            .receive(on: DispatchQueue.main)
            .map { _ in () }
            .prepend(())
            .weakCapture(player)
            .map { _, player in
                player.effectivePlaybackSpeed
            }
            .removeDuplicates()
            .sink { [weak self] speed in
                self?.notifyPlaybackSpeedChange(speed: speed)
            }
            .store(in: &cancellables)
    }

    public func disable() {
        cancellables = []
        streamingAnalytics = SCORStreamingAnalytics()
    }

    private func notify(playbackState: PlaybackState, isSeeking: Bool, isBuffering: Bool, player: Player) {
        guard !metadata.labels.isEmpty else { return }
        AnalyticsListener.capture(streamingAnalytics.configuration())
        streamingAnalytics.setProperties(for: player, streamType: metadata.streamType)
        streamingAnalytics.notifyChangePlaybackRate(player.effectivePlaybackSpeed)
        streamingAnalytics.notifyEvent(playbackState: playbackState, isSeeking: isSeeking, isBuffering: isBuffering)
    }

    private func notifyPlaybackSpeedChange(speed: Float) {
        streamingAnalytics.notifyChangePlaybackRate(speed)
    }

    private func updateMetadata(with metadata: Metadata) {
        let builder = SCORStreamingContentMetadataBuilder()
        builder.setCustomLabels(metadata.labels)
        let contentMetadata = SCORStreamingContentMetadata(builder: builder)
        streamingAnalytics.setMetadata(contentMetadata)
    }
}

private extension SCORStreamingAnalytics {
    private static func duration(for player: Player) -> Int {
        player.timeRange.isValid ? Int(player.timeRange.duration.seconds.toMilliseconds) : 0
    }

    private static func position(for player: Player) -> Int {
        player.time.isValid ? Int(player.time.seconds.toMilliseconds) : 0
    }

    private static func offset(for player: Player) -> Int {
        guard player.timeRange.isValid, player.time.isValid else { return 0 }
        let offset = player.timeRange.end - player.time
        return Int(offset.seconds.toMilliseconds)
    }

    private func notifyEvent(playbackState: PlaybackState) {
        switch playbackState {
        case .playing:
            notifyPlay()
        case .paused:
            notifyPause()
        case .ended:
            notifyEnd()
        default:
            break
        }
    }

    func setProperties(for player: Player, streamType: StreamType) {
        if streamType == .dvr {
            start(fromDvrWindowOffset: Self.offset(for: player))
            setDVRWindowLength(Self.duration(for: player))
        }
        else {
            start(fromPosition: Self.position(for: player))
        }
    }

    func notifyEvent(playbackState: PlaybackState, isSeeking: Bool, isBuffering: Bool) {
        switch (isSeeking, isBuffering) {
        case (true, true):
            notifySeekStart()
            notifyBufferStart()
        case (true, false):
            notifySeekStart()
            notifyBufferStop()
        case (false, true):
            notifyBufferStart()
        case (false, false):
            notifyBufferStop()
            notifyEvent(playbackState: playbackState)
        }
    }
}

public extension ComScoreTracker {
    /// Metadata.
    struct Metadata {
        let labels: [String: String]
        let streamType: StreamType

        static var empty: Self {
            .init(labels: [:], streamType: .unknown)
        }

        /// The initializer.
        /// - Parameters:
        ///   - labels: The labels.
        ///   - streamType: The stream type.
        public init(labels: [String: String], streamType: StreamType) {
            self.labels = labels
            self.streamType = streamType
        }
    }
}
