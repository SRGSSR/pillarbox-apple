//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import Foundation
import PillarboxPlayer

final class CommandersActStreamingAnalytics {
    var lastEvent: Event = .none

    private let posInterval: TimeInterval
    private let uptimeInterval: TimeInterval

    private var streamType: StreamType = .unknown
    private var isBuffering = false
    private var metadata: [String: String] = [:]
    private var playbackSpeed: Float = 1
    private var cancellables = Set<AnyCancellable>()
    private var playbackDuration: TimeInterval = 0

    private var time: CMTime = .zero
    private var range: CMTimeRange = .zero
    private var date = Date()

    private var isAdvancing: Bool {
        lastEvent == .play && !isBuffering
    }

    init(posInterval: TimeInterval = 30, uptimeInterval: TimeInterval = 60) {
        self.posInterval = posInterval
        self.uptimeInterval = uptimeInterval
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
        case (.pause, .seek), (.pause, .eof), (.seek, .pause), (.seek, .eof), (.eof, _), (.stop, _):
            break
        case let (.none, event) where event != .play:
            return
        default:
            sendEvent(event)
        }
    }

    func notify(streamType: StreamType) {
        update()
        if self.streamType != streamType {
            self.streamType = streamType
            updateHeartbeatsIfNeeded()
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
        updateHeartbeatsIfNeeded()

        Analytics.shared.sendEvent(commandersAct: .init(
            name: event.rawValue,
            labels: labels()
        ))
    }

    private func updateHeartbeatsIfNeeded() {
        if lastEvent == .play {
            uninstallHeartbeats()
            installHeartbeats()
        }
        else {
            uninstallHeartbeats()
        }
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
        }

        private let kind: Kind
        private let delay: TimeInterval
        private let interval: TimeInterval

        var name: String {
            kind.rawValue
        }

        static func pos(delay: TimeInterval, interval: TimeInterval) -> Self {
            .init(kind: .pos, delay: delay, interval: interval)
        }

        static func uptime(delay: TimeInterval, interval: TimeInterval) -> Self {
            .init(kind: .uptime, delay: delay, interval: interval)
        }

        func timer() -> AnyPublisher<Void, Never> {
            Timer.publish(every: interval, on: .main, in: .common)
                .autoconnect()
                .map { _ in }
                .prepend(())
                .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}

private extension CommandersActStreamingAnalytics {
    private func hearbeats() -> [Heartbeat] {
        switch streamType {
        case .onDemand:
            [.pos(delay: posInterval, interval: posInterval)]
        case .live, .dvr:
            [.pos(delay: posInterval, interval: posInterval), .uptime(delay: posInterval, interval: uptimeInterval)]
        default:
            []
        }
    }

    func installHeartbeats() {
        hearbeats().forEach { heartbeat in
            heartbeat.timer()
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
