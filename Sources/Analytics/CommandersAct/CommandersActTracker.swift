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
    private var properties: PlayerProperties?
    private var metadata: [String: String] = [:]
    private var lastEvent: Event = .none

    public init(configuration: Void) {}

    public func enable(for player: Player) {
        self.player = player
    }

    public func updateMetadata(with metadata: [String: String]) {
        self.metadata = metadata
    }

    public func updateProperties(with properties: PlayerProperties) {
        self.properties = properties

        if properties.isSeeking {
            notify(.seek, player: player)
        }
        else {
            switch properties.playbackState {
            case .playing:
                notify(.play, player: player)
            case .paused:
                notify(.pause, player: player)
            case .ended:
                notify(.eof, player: player)
            default:
                break
            }
        }
    }

    public func receiveMetricEvent(_ event: MetricEvent) {}

    public func disable(for player: Player) {
        notify(.stop, player: player)
    }
}

private extension CommandersActTracker {
    enum Event: String {
        case none
        case play
        case pause
        case seek
        case eof
        case stop
    }

    func notify(_ event: Event, player: Player?) {
        guard event != lastEvent else { return }

        switch (lastEvent, event) {
        case (.pause, .seek), (.pause, .eof), (.seek, .pause), (.seek, .eof), (.stop, _):
            break
        case (.none, _) where event != .play, (.eof, _) where event != .play:
            break
        default:
            Analytics.shared.sendEvent(commandersAct: .init(
                name: event.rawValue,
                labels: labels(player: player)
            ))
            lastEvent = event
        }
    }

    func labels(player: Player?) -> [String: String] {
        var labels = metadata

        labels["media_player_display"] = "Pillarbox"
        labels["media_player_version"] = Player.version

        labels["media_volume"] = volume(for: player)
        labels["media_audio_track"] = audioTrack(for: player)
        labels["media_audiodescription_on"] = audioDescription(for: player)
        labels["media_subtitles_on"] = subtitleOn(for: player)
        labels["media_subtitle_selection"] = subtitleSelection(for: player)

        switch properties?.streamType {
        case .onDemand:
            labels["media_position"] = String(mediaPosition(for: player))
        case .live:
            labels["media_position"] = String(playbackDuration())
            labels["media_timeshift"] = "0"
        case .dvr:
            labels["media_position"] = String(playbackDuration())
            labels["media_timeshift"] = String(timeshiftOffset(for: player))
        default:
            break
        }

        return labels
    }

    func mediaPosition(for player: Player?) -> Int {
        guard let time = player?.time, time.isValid else { return 0 }
        return Int(time.timeInterval())
    }

    func playbackDuration() -> Int {
        guard let metrics = properties?.metrics() else { return 0 }
        return Int(metrics.total.playbackDuration)
    }

    func timeshiftOffset(for player: Player?) -> Int {
        guard let time = player?.time, time.isValid, let range = properties?.seekableTimeRange else { return 0 }
        return Int((range.end - time).timeInterval())
    }

    func volume(for player: Player?) -> String {
        guard player?.isMuted == false else { return "0" }
        return String(Int(AVAudioSession.sharedInstance().outputVolume * 100))
    }

    func languageCode(from option: AVMediaSelectionOption?) -> String {
        option?.locale?.language.languageCode?.identifier.uppercased() ?? "UND"
    }

    func audioTrack(for player: Player?) -> String {
        if case let .on(option) = player?.currentMediaOption(for: .audible) {
            return languageCode(from: option)
        }
        else {
            return languageCode(from: nil)
        }
    }

    func audioDescription(for player: Player?) -> String {
        if case let .on(option) = player?.currentMediaOption(for: .audible), option.hasMediaCharacteristic(.describesVideoForAccessibility) {
            return "true"
        }
        else {
            return "false"
        }
    }

    func subtitleOn(for player: Player?) -> String {
        if case let .on(option) = player?.currentMediaOption(for: .legible), !option.hasMediaCharacteristic(.containsOnlyForcedSubtitles) {
            return "true"
        }
        else {
            return "false"
        }
    }

    func subtitleSelection(for player: Player?) -> String? {
        if case let .on(option) = player?.currentMediaOption(for: .legible), !option.hasMediaCharacteristic(.containsOnlyForcedSubtitles) {
            return languageCode(from: option)
        }
        else {
            return nil
        }
    }
}
