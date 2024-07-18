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
    private var lastEvent: Event = .none

    public init(configuration: Void) {}

    public func enable(for player: Player) {
        self.player = player
    }

    public func updateMetadata(with metadata: [String: String]) {}

    public func updateProperties(with properties: PlayerProperties) {
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
    func mediaPosition(for player: Player?) -> Int {
        guard let player else { return 0 }
        return Int(player.time.timeInterval())
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

    private func notify(_ event: Event, player: Player?) {
        guard event != lastEvent else { return }

        switch (lastEvent, event) {
        case (.pause, .seek), (.pause, .eof), (.seek, .pause), (.seek, .eof), (.stop, _):
            break
        case (.none, _) where event != .play, (.eof, _) where event != .play:
            break
        default:
            Analytics.shared.sendEvent(commandersAct: .init(
                name: event.rawValue,
                labels: ["media_position": String(mediaPosition(for: player))]
            ))
            lastEvent = event
        }
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
