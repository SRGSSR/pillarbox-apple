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
    private let streamingAnalytics = SCORStreamingAnalytics()
    private var cancellables = Set<AnyCancellable>()

    public init(configuration: Void, metadataPublisher: AnyPublisher<[String: String], Never>) {}

    public func enable(for player: Player) {
        streamingAnalytics.createPlaybackSession()
        streamingAnalytics.setMediaPlayerName("Pillarbox")
        streamingAnalytics.setMediaPlayerVersion(PackageInfo.version)

        Publishers.CombineLatest(player.$playbackState, player.$isSeeking)
            .weakCapture(player)
            .sink { [weak self] state, player in
                self?.notify(playbackState: state.0, isSeeking: state.1, player: player)
            }
            .store(in: &cancellables)
    }

    public func disable() {
        cancellables = []
    }

    private func notify(playbackState: PlaybackState, isSeeking: Bool, player: Player) {
        AnalyticsListener.capture(streamingAnalytics.configuration())

        streamingAnalytics.setProperties(for: player)

        switch (playbackState, isSeeking) {
        case (_, true):
            streamingAnalytics.notifySeekStart()
        case (.playing, _):
            streamingAnalytics.notifyPlay()
        case (.paused, _):
            streamingAnalytics.notifyPause()
        case (.ended, _):
            streamingAnalytics.notifyEnd()
        default:
            break
        }
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

    func setProperties(for player: Player) {
        if player.streamType == .dvr {
            start(fromDvrWindowOffset: Self.offset(for: player))
            setDVRWindowLength(Self.duration(for: player))
        }
        else {
            start(fromPosition: Self.position(for: player))
        }
    }
}
