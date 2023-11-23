//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import Foundation
import Player

final class CommandersActStreamingAnalytics {
    var lastEvent: Event = .none
    private var metadata: [String: String] = [:]

    private let streamType: StreamType
    private let heartbeats: [Heartbeat]

    private var isBuffering = false
    private var playbackSpeed: Float = 1
    private var cancellables = Set<AnyCancellable>()
    private var playbackDuration: TimeInterval = 0

    private var time: CMTime = .zero
    private var range: CMTimeRange = .zero
    private var date = Date()

    private var isAdvancing: Bool {
        lastEvent == .play && !isBuffering
    }

    // TODO: The stream type should be provided with a setter, not at initialization time. Heartbeats should
    //       be adjusted accordingly.
    init(streamType: StreamType, heartbeats: [Heartbeat] = [.pos(), .uptime()]) {
        self.streamType = streamType
        self.heartbeats = heartbeats
    }

    private func update() {
        let interval = CMTime(seconds: Date().timeIntervalSince(date), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        update(time: time(after: interval), range: range(after: interval))
    }

    func update(time: CMTime, range: CMTimeRange) {
        let date = Date()
        if lastEvent == .play, !isBuffering {
            playbackDuration += date.timeIntervalSince(self.date)
        }
        self.time = time
        self.range = range
        self.date = date
    }

    func notify(_ event: Event) {
        guard event != lastEvent else { return }

        switch (lastEvent, event) {
        case (.pause, .seek), (.pause, .eof):
            return
        case (.seek, .pause), (.seek, .eof):
            return
        case (.eof, _), (.stop, _):
            return
        case let (.none, event) where event != .play:
            return
        default:
            sendEvent(event)
        }
    }

    func notify(isBuffering: Bool) {
        update()
        self.isBuffering = isBuffering
    }

    func notifyPlaybackSpeed(_ playbackSpeed: Float) {
        update()
        self.playbackSpeed = playbackSpeed
    }

    func setMetadata(value: String?, forKey key: String) {
        metadata[key] = value
    }

    private func sendEvent(_ event: Event) {
        update()
        lastEvent = event

        if event == .play {
            installHeartbeats()
        }
        else {
            uninstallHeartbeats()
        }

        Analytics.shared.sendEvent(commandersAct: .init(
            name: event.rawValue,
            labels: labels()
        ))
    }

    private func labels() -> [String: String] {
        var labels = metadata
        let interval = CMTime(seconds: Date().timeIntervalSince(date), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        switch streamType {
        case .onDemand:
            labels["media_position"] = String(Int(time(after: interval).timeInterval()))
        case .live:
            labels["media_position"] = String(Int(playbackDuration(after: interval)))
            labels["media_timeshift"] = "0"
        case .dvr:
            labels["media_position"] = String(Int(playbackDuration(after: interval)))
            labels["media_timeshift"] = String(Int((range(after: interval).end - time(after: interval)).timeInterval()))
        default:
            break
        }
        return labels
    }

    private func time(after interval: CMTime) -> CMTime {
        isAdvancing ? time + CMTimeMultiplyByFloat64(interval, multiplier: Float64(playbackSpeed)) : time
    }

    private func range(after interval: CMTime) -> CMTimeRange {
        .init(start: range.start + interval, duration: range.duration)
    }

    private func playbackDuration(after interval: CMTime) -> TimeInterval {
        isAdvancing ? playbackDuration + interval.seconds : playbackDuration
    }

    deinit {
        notify(.stop)
    }
}

extension CommandersActStreamingAnalytics {
    enum Event: String {
        case none
        case play
        case pause
        case seek
        case eof
        case stop
    }

    struct Heartbeat {
        enum Kind: String {
            case pos
            case uptime

            private var supportedStreamTypes: [StreamType] {
                switch self {
                case .pos:
                    return [.onDemand, .live, .dvr]
                case .uptime:
                    return [.live, .dvr]
                }
            }

            func isSupported(for streamType: StreamType) -> Bool {
                supportedStreamTypes.contains(streamType)
            }
        }

        private let kind: Kind
        private let delay: TimeInterval
        private let interval: TimeInterval

        var name: String {
            kind.rawValue
        }

        static func pos(delay: TimeInterval = 30, interval: TimeInterval = 30) -> Self {
            .init(kind: .pos, delay: delay, interval: interval)
        }

        static func uptime(delay: TimeInterval = 30, interval: TimeInterval = 60) -> Self {
            .init(kind: .uptime, delay: delay, interval: interval)
        }

        func timer(for streamType: StreamType) -> AnyPublisher<Void, Never>? {
            guard kind.isSupported(for: streamType) else { return nil }
            return Timer.publish(every: interval, on: .main, in: .common)
                .autoconnect()
                .map { _ in }
                .prepend(())
                .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}

private extension CommandersActStreamingAnalytics {
    func installHeartbeats() {
        heartbeats.forEach { heartbeat in
            guard let timer = heartbeat.timer(for: streamType) else { return }
            timer
                .sink { [weak self] _ in
                    self?.sendHeartbeat(heartbeat)
                }
                .store(in: &cancellables)
        }
    }

    func uninstallHeartbeats() {
        cancellables = []
    }

    private func sendHeartbeat(_ heartbeat: Heartbeat) {
        Analytics.shared.sendEvent(commandersAct: .init(
            name: heartbeat.name,
            labels: labels()
        ))
    }
}
