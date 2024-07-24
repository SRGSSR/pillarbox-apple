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
    private var metadata: [String: String] = [:]
    private var lastEvent: Event = .none

    public init(configuration: Void) {}

    public func enable(for player: AVPlayer) {}

    public func updateMetadata(with metadata: [String: String]) {
        self.metadata = metadata
    }

    public func updateProperties(with properties: PlayerProperties, time: CMTime) {
        if properties.isSeeking {
            notify(.seek, properties: properties, time: time)
        }
        else {
            switch properties.playbackState {
            case .playing:
                notify(.play, properties: properties, time: time)
            case .paused:
                notify(.pause, properties: properties, time: time)
            case .ended:
                notify(.eof, properties: properties, time: time)
            default:
                break
            }
        }
    }

    public func receiveMetricEvent(_ event: MetricEvent) {}

    public func disable(with properties: PlayerProperties, time: CMTime) {
        notify(.stop, properties: properties, time: time)
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

    func notify(_ event: Event, properties: PlayerProperties, time: CMTime) {
        guard event != lastEvent else { return }

        switch (lastEvent, event) {
        case (.pause, .seek), (.pause, .eof), (.seek, .pause), (.seek, .eof), (.stop, _):
            break
        case (.none, _) where event != .play, (.eof, _) where event != .play:
            break
        default:
            Analytics.shared.sendEvent(commandersAct: .init(
                name: event.rawValue,
                labels: labels(properties: properties, time: time)
            ))
            lastEvent = event
        }
    }

    func labels(properties: PlayerProperties, time: CMTime) -> [String: String] {
        var labels = metadata

        labels["media_player_display"] = "Pillarbox"
        labels["media_player_version"] = Player.version

        labels["media_volume"] = volume(for: properties)
        labels["media_audio_track"] = audioTrack(for: properties)
        labels["media_audiodescription_on"] = audioDescription(for: properties)
        labels["media_subtitles_on"] = subtitleOn(for: properties)
        labels["media_subtitle_selection"] = subtitleSelection(for: properties)

        switch properties.streamType {
        case .onDemand:
            labels["media_position"] = String(mediaPosition(for: time))
        case .live:
            labels["media_position"] = String(playbackDuration(for: properties))
            labels["media_timeshift"] = "0"
        case .dvr:
            labels["media_position"] = String(playbackDuration(for: properties))
            labels["media_timeshift"] = String(timeshiftOffset(for: properties, time: time))
        default:
            break
        }

        return labels
    }

    func volume(for properties: PlayerProperties) -> String {
        guard !properties.isMuted else { return "0" }
        return String(Int(AVAudioSession.sharedInstance().outputVolume * 100))
    }

    func audioTrack(for properties: PlayerProperties) -> String {
        if case let .on(option) = properties.currentMediaOption(for: .audible) {
            return languageCode(from: option)
        }
        else {
            return languageCode(from: nil)
        }
    }

    func audioDescription(for properties: PlayerProperties) -> String {
        if case let .on(option) = properties.currentMediaOption(for: .audible), option.hasMediaCharacteristic(.describesVideoForAccessibility) {
            return "true"
        }
        else {
            return "false"
        }
    }

    func subtitleOn(for properties: PlayerProperties) -> String {
        if case let .on(option) = properties.currentMediaOption(for: .legible), !option.hasMediaCharacteristic(.containsOnlyForcedSubtitles) {
            return "true"
        }
        else {
            return "false"
        }
    }

    func subtitleSelection(for properties: PlayerProperties) -> String? {
        if case let .on(option) = properties.currentMediaOption(for: .legible), !option.hasMediaCharacteristic(.containsOnlyForcedSubtitles) {
            return languageCode(from: option)
        }
        else {
            return nil
        }
    }

    func mediaPosition(for time: CMTime) -> Int {
        Int(time.timeInterval())
    }

    func playbackDuration(for properties: PlayerProperties) -> Int {
        guard let metrics = properties.metrics() else { return 0 }
        return Int(metrics.total.playbackDuration)
    }

    func timeshiftOffset(for properties: PlayerProperties, time: CMTime) -> Int {
        guard time.isValid else { return 0 }
        return Int((properties.seekableTimeRange.end - time).timeInterval())
    }

    func languageCode(from option: AVMediaSelectionOption?) -> String {
        option?.locale?.language.languageCode?.identifier.uppercased() ?? "UND"
    }
}
