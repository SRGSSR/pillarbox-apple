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
    var lastEvent: Event = .play
    private var metadata: [String: String] = [:]

    private let streamType: StreamType
    private let heartbeats: [Heartbeat]

    private var isBuffering = false
    private var playbackSpeed: Float = 1
    private var cancellables = Set<AnyCancellable>()
    private var playbackDuration: TimeInterval = 0

    private var lastEventTime: CMTime = .zero
    private var lastEventRange: CMTimeRange = .zero
    private var lastEventDate = Date()

    private var isAdvancing: Bool {
        lastEvent == .play && !isBuffering
    }

    init(streamType: StreamType, heartbeats: [Heartbeat] = [.pos(), .uptime()]) {
        self.streamType = streamType
        self.heartbeats = heartbeats
    }

    func setMetadata(_ metadata: [String: String]) {
        self.metadata = metadata
    }

    private func update(time: CMTime, range: CMTimeRange) {
        lastEventTime = time
        lastEventRange = range
        lastEventDate = Date()
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
        default:
            sendEvent(event)
        }
    }

    func notify(isBuffering: Bool) {
        self.isBuffering = isBuffering
    }

    func notifyPlaybackSpeed(_ playbackSpeed: Float) {
        self.playbackSpeed = playbackSpeed
    }

    private func sendEvent(_ event: Event) {
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
        switch streamType {
        case .onDemand:
            let interval = CMTime(seconds: Date().timeIntervalSince(lastEventDate), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            labels["media_position"] = String(Int(eventTime(after: interval).timeInterval()))
        case .live:
            labels["media_position"] = String(Int(playbackDuration))
            labels["media_timeshift"] = "0"
        case .dvr:
            let interval = CMTime(seconds: Date().timeIntervalSince(lastEventDate), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            labels["media_position"] = String(Int(playbackDuration))
            labels["media_timeshift"] = String(Int((eventRange(after: interval).end - eventTime(after: interval)).timeInterval()))
        default:
            break
        }
        return labels
    }

    private func eventTime(after interval: CMTime) -> CMTime {
        isAdvancing ? lastEventTime + CMTimeMultiplyByFloat64(interval, multiplier: Float64(playbackSpeed)) : lastEventTime
    }

    private func eventRange(after interval: CMTime) -> CMTimeRange {
        isAdvancing ? .init(start: lastEventRange.start + interval, duration: lastEventRange.duration) : lastEventRange
    }

    deinit {
        notify(.stop)
    }
}

extension CommandersActStreamingAnalytics {
    enum Event: String {
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
