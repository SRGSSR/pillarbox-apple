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
    private var lastLabels: [String: String] = [:]

    private let streamType: StreamType
    private let heartbeatInterval: HeartbeatInterval
    private let update: () -> EventData?

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

    init(streamType: StreamType, heartbeatInterval: HeartbeatInterval = .default, update: @escaping () -> EventData?) {
        self.streamType = streamType
        self.heartbeatInterval = heartbeatInterval
        self.update = update
        sendEvent(.play)
    }

    func notify(isBuffering: Bool) {
        updateTimeTracking(eventData: eventData())
        self.isBuffering = isBuffering
    }

    func notify(_ event: Event) {
        notify(event, eventData: eventData())
    }

    func notifyPlaybackSpeed(_ playbackSpeed: Float) {
        updateTimeTracking(eventData: eventData())
        self.playbackSpeed = playbackSpeed
    }

    private func notify(_ event: Event, eventData: EventData) {
        guard event != lastEvent else { return }

        switch (lastEvent, event) {
        case (.pause, .seek), (.pause, .eof):
            return
        case (.seek, .pause), (.seek, .eof):
            return
        case (.eof, _), (.stop, _):
            return
        default:
            sendEvent(event, eventData: eventData)
        }
    }

    private func sendEvent(_ event: Event) {
        sendEvent(event, eventData: eventData())
    }

    private func sendEvent(_ event: Event, eventData: EventData) {
        updateTimeTracking(eventData: eventData)

        lastEvent = event
        lastLabels = eventData.labels

        if event == .play {
            installHeartbeats()
        }
        else {
            uninstallHeartbeats()
        }

        Analytics.shared.sendStreamingEvent(commandersAct: .init(
            name: event.rawValue,
            labels: labels(eventData: eventData)
        ))
    }

    private func labels(eventData: EventData) -> [String: String] {
        var labels = eventData.labels
        switch streamType {
        case .onDemand:
            labels["media_position"] = String(Int(eventData.time.timeInterval()))
        case .live:
            labels["media_position"] = String(Int(playbackDuration))
            labels["media_timeshift"] = "0"
        case .dvr:
            labels["media_position"] = String(Int(playbackDuration))
            labels["media_timeshift"] = String(Int((eventData.range.end - eventData.time).timeInterval()))
        default:
            break
        }
        return labels
    }

    private func updateTimeTracking(eventData: EventData) {
        if lastEvent == .play, !isBuffering {
            playbackDuration += Date().timeIntervalSince(lastEventDate)
        }
        lastEventTime = eventData.time
        lastEventRange = eventData.range
        lastEventDate = Date()
    }

    private func eventTime(after interval: CMTime) -> CMTime {
        let multiplier = (streamType == .onDemand) ? Float64(playbackSpeed) : 1
        return isAdvancing ? lastEventTime + CMTimeMultiplyByFloat64(interval, multiplier: multiplier) : lastEventTime
    }

    private func eventRange(after interval: CMTime) -> CMTimeRange {
        isAdvancing ? .init(start: lastEventRange.start + interval, duration: lastEventRange.duration) : lastEventRange
    }

    private func eventData() -> EventData {
        update() ?? .empty
    }

    deinit {
        let interval = CMTime(seconds: Date().timeIntervalSince(lastEventDate), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let eventData = EventData(labels: lastLabels, time: eventTime(after: interval), range: eventRange(after: interval))
        notify(.stop, eventData: eventData)
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

    struct EventData {
        var labels: [String: String]
        var time: CMTime
        var range: CMTimeRange

        static var empty: Self {
            .init(labels: [:], time: .zero, range: .zero)
        }
    }

    struct HeartbeatInterval {
        let pos: TimeInterval
        let uptime: TimeInterval

        static var `default`: Self {
            .init(pos: 30, uptime: 60)
        }
    }
}

private extension CommandersActStreamingAnalytics {
    enum Heartbeat: String {
        case pos
        case uptime
    }

    func installHeartbeats() {
        timer(for: .pos, interval: heartbeatInterval.pos)
        if [.live, .dvr].contains(streamType) {
            timer(for: .uptime, interval: heartbeatInterval.uptime)
        }
    }

    func uninstallHeartbeats() {
        cancellables = []
    }

    private func timer(for heartbeat: Heartbeat, interval: TimeInterval) {
        Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.sendHeartbeat(heartbeat)
            }
            .store(in: &cancellables)
    }

    private func sendHeartbeat(_ heartbeat: Heartbeat) {
        let eventData = eventData()
        updateTimeTracking(eventData: eventData)
        Analytics.shared.sendStreamingEvent(commandersAct: .init(
            name: heartbeat.rawValue,
            labels: labels(eventData: eventData)
        ))
    }
}
