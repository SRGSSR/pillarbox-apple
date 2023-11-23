//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Foundation
import Player

/// A Commanders Act tracker for streaming.
///
/// This tracker implements streaming measurements according to SRG SSR official specifications.
///
/// Analytics have to be properly started for the tracker to collect data, see `Analytics.start(with:)`.
public final class CommandersActTracker: PlayerItemTracker {
    private var streamingAnalytics: CommandersActStreamingAnalytics?
    private var metadata: Metadata = .empty
    private weak var player: Player?

    public init(configuration: Void) {}

    public func enable(for player: Player) {
        self.player = player
    }

    public func updateMetadata(with metadata: Metadata) {
        self.metadata = metadata
    }

    public func updateProperties(with properties: PlayerProperties) {
        if properties.playbackState == .playing, streamingAnalytics == nil {
            streamingAnalytics = CommandersActStreamingAnalytics(streamType: metadata.streamType)
        }

        streamingAnalytics?.update(time: player?.time ?? .zero, range: properties.seekableTimeRange)
        streamingAnalytics?.notify(isBuffering: properties.isBuffering)
        streamingAnalytics?.notifyPlaybackSpeed(properties.rate)

        if properties.isSeeking {
            streamingAnalytics?.notify(.seek)
        }
        else {
            switch properties.playbackState {
            case .playing:
                streamingAnalytics?.notify(.play)
            case .paused:
                streamingAnalytics?.notify(.pause)
            case .ended:
                streamingAnalytics?.notify(.eof)
            default:
                break
            }
        }
    }

    public func disable() {
        streamingAnalytics = nil
        player = nil
    }
}

private extension CommandersActTracker {
    private func volume(for player: Player) -> Int {
        guard !player.isMuted else { return 0 }
        return Int(AVAudioSession.sharedInstance().outputVolume * 100)
    }

    private func languageCode(from option: AVMediaSelectionOption?) -> String {
        option?.locale?.language.languageCode?.identifier.uppercased() ?? "UND"
    }

    private func audioTrack(for player: Player) -> String {
        switch player.currentMediaOption(for: .audible) {
        case let .on(option):
            return languageCode(from: option)
        default:
            return languageCode(from: nil)
        }
    }

    private func subtitleLabels(for player: Player) -> [String: String] {
        switch player.currentMediaOption(for: .legible) {
        case let .on(option) where !option.hasMediaCharacteristic(.containsOnlyForcedSubtitles):
            return [
                "media_subtitles_on": "true",
                "media_subtitle_selection": "\(languageCode(from: option))"
            ]
        default:
            return [
                "media_subtitles_on": "false"
            ]
        }
    }

    func labels(for player: Player) -> [String: String] {
        metadata.labels
            .merging([
                "media_player_display": "Pillarbox",
                "media_player_version": Player.version,
                "media_volume": "\(volume(for: player))",
                "media_audio_track": "\(audioTrack(for: player))"
            ]) { _, new in new }
            .merging(subtitleLabels(for: player)) { _, new in new }
    }
}

public extension CommandersActTracker {
    /// Commanders Act tracker metadata.
    struct Metadata {
        let labels: [String: String]
        let streamType: StreamType

        static var empty: Self {
            .init(labels: [:], streamType: .unknown)
        }

        /// Creates Commanders Act metadata.
        ///
        /// - Parameters:
        ///   - labels: The labels associated with the content being played.
        ///   - streamType: The stream type.
        public init(labels: [String: String], streamType: StreamType) {
            self.labels = labels
            self.streamType = streamType
        }
    }
}
