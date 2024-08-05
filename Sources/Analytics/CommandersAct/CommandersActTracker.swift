//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
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
    private let stopwatch = Stopwatch()
    private let heartbeat = CommandersActHeartbeat()
    private var cancellable: AnyCancellable?

    public init(configuration: Void) {}

    public func enable(for player: AVPlayer) {}

    public func updateMetadata(to metadata: [String: String]) {
        self.metadata = metadata
    }

    public func updateProperties(to properties: PlayerProperties) {
        if properties.isSeeking {
            notify(.seek, properties: properties)
        }
        else {
            switch properties.playbackState {
            case .playing:
                notify(.play, properties: properties)
            case .paused:
                notify(.pause, properties: properties)
            case .ended:
                notify(.eof, properties: properties)
            default:
                break
            }
        }
    }

    public func updateMetricEvents(to events: [MetricEvent]) {}

    public func disable(with properties: PlayerProperties) {
        notify(.stop, properties: properties)
        stopwatch.reset()
        heartbeat.reset()
    }
}

private extension CommandersActTracker {
    func notify(_ event: Event, properties: PlayerProperties) {
        updateStopwatch(event: event, properties: properties)
        sendEventIfNeeded(event: event, properties: properties)
        heartbeat.update(with: properties, labels: labels)
    }

    func updateStopwatch(event: Event, properties: PlayerProperties) {
        if event == .play && !properties.isBuffering {
            stopwatch.start()
        }
        else {
            stopwatch.stop()
        }
    }

    func sendEventIfNeeded(event: Event, properties: PlayerProperties) {
        guard event != lastEvent else { return }

        switch (lastEvent, event) {
        case (.pause, .seek), (.pause, .eof), (.seek, .pause), (.seek, .eof), (.stop, _):
            break
        case (.none, _) where event != .play, (.eof, _) where event != .play:
            break
        default:
            Analytics.shared.sendEvent(commandersAct: .init(
                name: event.rawValue,
                labels: labels(from: properties)
            ))
            lastEvent = event
        }
    }
}

private extension CommandersActTracker {
    func labels(from properties: PlayerProperties) -> [String: String] {
        var labels = metadata

        labels["media_player_display"] = "Pillarbox"
        labels["media_player_version"] = Player.version

        labels["media_volume"] = volume(from: properties)
        labels["media_audio_track"] = audioTrack(from: properties)
        labels["media_audiodescription_on"] = audioDescription(from: properties)
        labels["media_subtitles_on"] = subtitleOn(from: properties)
        labels["media_subtitle_selection"] = subtitleSelection(from: properties)

        switch properties.streamType {
        case .onDemand:
            labels["media_position"] = String(mediaPosition(from: properties))
        case .live:
            labels["media_position"] = String(playbackDuration())
            labels["media_timeshift"] = "0"
        case .dvr:
            labels["media_position"] = String(playbackDuration())
            labels["media_timeshift"] = String(timeshiftOffset(from: properties))
        default:
            break
        }

        return labels
    }

    func volume(from properties: PlayerProperties) -> String {
        guard !properties.isMuted else { return "0" }
        return String(Int(AVAudioSession.sharedInstance().outputVolume * 100))
    }

    func audioTrack(from properties: PlayerProperties) -> String {
        if case let .on(option) = properties.currentMediaOption(for: .audible) {
            return languageCode(from: option)
        }
        else {
            return languageCode(from: nil)
        }
    }

    func audioDescription(from properties: PlayerProperties) -> String {
        if case let .on(option) = properties.currentMediaOption(for: .audible), option.hasMediaCharacteristic(.describesVideoForAccessibility) {
            return "true"
        }
        else {
            return "false"
        }
    }

    func subtitleOn(from properties: PlayerProperties) -> String {
        if case let .on(option) = properties.currentMediaOption(for: .legible), !option.hasMediaCharacteristic(.containsOnlyForcedSubtitles) {
            return "true"
        }
        else {
            return "false"
        }
    }

    func subtitleSelection(from properties: PlayerProperties) -> String? {
        if case let .on(option) = properties.currentMediaOption(for: .legible), !option.hasMediaCharacteristic(.containsOnlyForcedSubtitles) {
            return languageCode(from: option)
        }
        else {
            return nil
        }
    }

    func mediaPosition(from properties: PlayerProperties) -> Int {
        Int(properties.time().timeInterval())
    }

    func playbackDuration() -> Int {
        Int(stopwatch.time())
    }

    func timeshiftOffset(from properties: PlayerProperties) -> Int {
        Int(properties.endOffset().timeInterval())
    }

    func languageCode(from option: AVMediaSelectionOption?) -> String {
        option?.locale?.language.languageCode?.identifier.uppercased() ?? "UND"
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
}
