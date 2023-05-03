//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import Player

/// Stream tracker for Commanders Act.
public final class CommandersActTracker: PlayerItemTracker {
    private var cancellables = Set<AnyCancellable>()
    private var streamingAnalytics: CommandersActStreamingAnalytics?

    public init(configuration: Void, metadataPublisher: AnyPublisher<[String: String], Never>) {}

    private static func eventName(for playbackState: PlaybackState) -> String? {
        switch playbackState {
        case .playing:
            return "play"
        case .paused:
            return "pause"
        default:
            return nil
        }
    }

    public func enable(for player: Player) {
        Publishers.CombineLatest(player.$playbackState, player.$isSeeking)
            .map { (playbackState: $0, isSeeking: $1) }
            .weakCapture(player)
            .sink { [weak self] state, player in
                self?.notify(playbackState: state.playbackState, isSeeking: state.isSeeking, player: player)
            }
            .store(in: &cancellables)
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func notify(playbackState: PlaybackState, isSeeking: Bool, player: Player) {
        if isSeeking {
            streamingAnalytics?.notify(.seek, at: player.time, in: player.timeRange)
        }
        else {
            switch playbackState {
            case .playing:
                if streamingAnalytics == nil {
                    streamingAnalytics = CommandersActStreamingAnalytics(
                        at: player.time,
                        in: player.timeRange,
                        isLive: [.dvr, .live].contains(player.streamType)
                    )
                }
                else {
                    streamingAnalytics?.notify(.play, at: player.time, in: player.timeRange)
                }
            case .paused:
                streamingAnalytics?.notify(.pause, at: player.time, in: player.timeRange)
            case .ended:
                streamingAnalytics?.notify(.eof, at: player.time, in: player.timeRange)
            case .failed:
                streamingAnalytics?.notify(.stop, at: player.time, in: player.timeRange)
            default:
                break
            }
        }
    }

    public func disable() {
        cancellables = []
        streamingAnalytics = nil
    }
}
