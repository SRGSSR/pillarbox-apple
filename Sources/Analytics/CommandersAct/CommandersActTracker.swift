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
    private weak var player: Player?
    private var lastPlaybackState: PlaybackState = .idle

    public init(configuration: Void) {}

    public func enable(for player: Player) {
        self.player = player
    }

    public func updateMetadata(with metadata: [String: String]) {}

    public func updateProperties(with properties: PlayerProperties) {
        guard properties.playbackState != lastPlaybackState else { return }
        lastPlaybackState = properties.playbackState

        switch properties.playbackState {
        case .playing:
            Analytics.shared.sendEvent(commandersAct: .init(
                name: "play",
                labels: ["media_position": String(mediaPosition(for: player))]
            ))
        case .paused:
            Analytics.shared.sendEvent(commandersAct: .init(
                name: "pause",
                labels: ["media_position": String(mediaPosition(for: player))]
            ))
        case .ended:
            Analytics.shared.sendEvent(commandersAct: .init(
                name: "eof",
                labels: ["media_position": String(mediaPosition(for: player))]
            ))
        default:
            break
        }
    }

    public func receiveMetricEvent(_ event: MetricEvent) {}

    public func disable(for player: Player) {
        Analytics.shared.sendEvent(commandersAct: .init(
            name: "stop",
            labels: ["media_position": String(mediaPosition(for: player))]
        ))
    }
}

private extension CommandersActTracker {
    func mediaPosition(for player: Player?) -> Int {
        guard let player else { return 0 }
        return Int(player.time.timeInterval())
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
