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

/// Stream tracker for comScore.
public final class ComScoreTracker: PlayerItemTracker {
    private var streamingAnalytics = SCORStreamingAnalytics()
    private var cancellables = Set<AnyCancellable>()
    @Published private var metadata: [String: String] = [:]

    public init(configuration: Void, metadataPublisher: AnyPublisher<[String: String], Never>) {
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
    }

    public func disable() {
        cancellables = []
        streamingAnalytics = SCORStreamingAnalytics()
    }

    private func notify(playbackState: PlaybackState, isSeeking: Bool, isBuffering: Bool, player: Player) {
        AnalyticsListener.capture(streamingAnalytics.configuration())
        guard !metadata.isEmpty else { return }
        streamingAnalytics.setProperties(for: player)
        streamingAnalytics.notifyEvent(playbackState: playbackState, isSeeking: isSeeking, isBuffering: isBuffering)
    }

    private func updateMetadata(with metadata: [String: String]) {
        let builder = SCORStreamingContentMetadataBuilder()
        builder.setCustomLabels(metadata)
        let metadata = SCORStreamingContentMetadata(builder: builder)
        streamingAnalytics.setMetadata(metadata)
    }
}

private extension SCORStreamingAnalytics {
    private static func duration(for player: Player) -> Int {
        player.timeRange.isValid ? Int(player.timeRange.duration.seconds * 1000) : 0
    }

    private static func position(for player: Player) -> Int {
        player.time.isValid ? Int(player.time.seconds * 1000) : 0
    }

    private static func offset(for player: Player) -> Int {
        guard player.timeRange.isValid, player.time.isValid else { return 0 }
        let offset = player.timeRange.end - player.time
        return Int(offset.seconds * 1000)
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

    func setProperties(for player: Player) {
        if player.streamType == .dvr {
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
