//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFAudio
import Combine
import Foundation
import Player

/// Stream tracker for Commanders Act.
public final class CommandersActTracker: PlayerItemTracker {
    private var cancellables = Set<AnyCancellable>()
    private var streamingAnalytics: CommandersActStreamingAnalytics?
    @Published private var metadata: Metadata = .empty

    public init(configuration: Void, metadataPublisher: AnyPublisher<Metadata, Never>) {
        metadataPublisher.assign(to: &$metadata)
    }

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

        player.$isBuffering
            .weakCapture(player)
            .sink { [weak self] isBuffering, player in
                self?.streamingAnalytics?.notify(isBuffering: isBuffering, time: player.time, range: player.timeRange)
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
                        labels: labels(for: player),
                        at: player.time,
                        in: player.timeRange,
                        streamType: metadata.streamType
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

extension CommandersActTracker {
    private var volume: Float {
        AVAudioSession.sharedInstance().outputVolume * 100
    }

    private func bitrate(for player: Player) -> Int {
        guard let event = player.systemPlayer.currentItem?.accessLog()?.events.last else { return 0 }
        return Int(max(event.indicatedBitrate, 0))
    }

    func labels(for player: Player) -> [String: String] {
        metadata.labels.merging([
            "media_player_display": "Pillarbox",
            "media_player_version": PackageInfo.version,
            "media_volume": "\(volume)",
            "media_playback_rate": "1",
            "media_bandwidth": "\(bitrate(for: player))"
        ]) { _, new in new }
    }
}

public extension CommandersActTracker {
    /// Metadata
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
