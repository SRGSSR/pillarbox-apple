//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Foundation
import PillarboxPlayer

/// A Commanders Act tracker for streaming.
///
/// This tracker implements streaming measurements according to SRG SSR official specifications.
///
/// Analytics have to be properly started for the tracker to collect data, see `Analytics.start(with:)`.
public final class CommandersActTracker: PlayerItemTracker {
    private lazy var streamingAnalytics = CommandersActStreamingAnalytics()
    private var metadata: [String: String] = [:]
    private weak var player: Player?

    public init(configuration: Void) {}

    public func enable(for player: Player) {
        self.player = player
    }

    public func updateMetadata(with metadata: [String: String]) {
        self.metadata = metadata
    }

    public func updateProperties(with properties: PlayerProperties) {
        streamingAnalytics.notify(streamType: properties.streamType)

        streamingAnalytics.setMetadata(value: "Pillarbox", forKey: "media_player_display")
        streamingAnalytics.setMetadata(value: Player.version, forKey: "media_player_version")
        streamingAnalytics.setMetadata(for: player)

        metadata.forEach { key, value in
            streamingAnalytics.setMetadata(value: value, forKey: key)
        }

        streamingAnalytics.update(time: player?.time ?? .zero, range: properties.seekableTimeRange)
        streamingAnalytics.notify(isBuffering: properties.isBuffering)
        streamingAnalytics.notifyPlaybackSpeed(properties.rate)

        if properties.isSeeking {
            streamingAnalytics.notify(.seek)
        }
        else {
            switch (properties.playbackState, properties.isBuffering) {
            case (.playing, false):
                streamingAnalytics.notify(.play)
            case (.paused, false):
                streamingAnalytics.notify(.pause)
            case (.ended, false):
                streamingAnalytics.notify(.eof)
            default:
                break
            }
        }
    }

    public func disable() {
        streamingAnalytics = CommandersActStreamingAnalytics()
        player = nil
    }
}

private extension CommandersActStreamingAnalytics {
    func setMetadata(for player: Player?) {
        guard let player else { return }
        setMetadata(value: volume(for: player), forKey: "media_volume")
        setMetadata(value: audioTrack(for: player), forKey: "media_audio_track")
        setMetadata(value: audioDescription(for: player), forKey: "media_audiodescription_on")
        setMetadata(value: subtitleOn(for: player), forKey: "media_subtitles_on")
        setMetadata(value: subtitleSelection(for: player), forKey: "media_subtitle_selection")
    }

    private func volume(for player: Player) -> String {
        guard !player.isMuted else { return "0" }
        return String(Int(AVAudioSession.sharedInstance().outputVolume * 100))
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

    private func audioDescription(for player: Player) -> String? {
        switch player.currentMediaOption(for: .audible) {
        case let .on(option):
            return option.hasMediaCharacteristic(.describesVideoForAccessibility) ? "true" : "false"
        default:
            return nil
        }
    }

    private func subtitleOn(for player: Player) -> String {
        switch player.currentMediaOption(for: .legible) {
        case let .on(option) where !option.hasMediaCharacteristic(.containsOnlyForcedSubtitles):
            return "true"
        default:
            return "false"
        }
    }

    private func subtitleSelection(for player: Player) -> String? {
        switch player.currentMediaOption(for: .legible) {
        case let .on(option) where !option.hasMediaCharacteristic(.containsOnlyForcedSubtitles):
            return languageCode(from: option)
        default:
            return nil
        }
    }
}
