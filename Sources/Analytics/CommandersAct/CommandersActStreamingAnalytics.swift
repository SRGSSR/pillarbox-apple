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

    private let streamType: StreamType
    private let update: () -> EventData?
    private var isBuffering = false
    private var cancellables = Set<AnyCancellable>()
    private var playbackDuration: TimeInterval = 0
    private var lastEventTime: CMTime = .zero
    private var lastEventRange: CMTimeRange = .zero
    private var lastEventDate = Date()
    private var isAdvancing: Bool {
        lastEvent == .play && !isBuffering
    }

    init(streamType: StreamType, update: @escaping () -> EventData?) {
        self.streamType = streamType
        self.update = update
        sendEvent(.play)
    }

    func notify(isBuffering: Bool) {
        updateReferences(eventData: eventData())
        self.isBuffering = isBuffering
    }

    func notify(_ event: Event) {
        notify(event, eventData: eventData())
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
        updateReferences(eventData: eventData)
        lastEvent = event

        if event == .play {
            installHeartbeats()
        }
        else {
            uninstallHeartbeats()
        }

        Analytics.shared.sendCommandersActStreamingEvent(
            name: event.rawValue,
            labels: labels(eventData: eventData)
        )
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

    private func updateReferences(eventData: EventData) {
        if lastEvent == .play, !isBuffering {
            playbackDuration += Date().timeIntervalSince(lastEventDate)
        }
        lastEventTime = eventData.time
        lastEventRange = eventData.range
        lastEventDate = Date()
    }

    private func eventTime(after interval: CMTime) -> CMTime {
        isAdvancing ? lastEventTime + interval : lastEventTime
    }

    private func eventRange(after interval: CMTime) -> CMTimeRange {
        isAdvancing ? .init(start: lastEventRange.start + interval, duration: lastEventRange.duration) : lastEventRange
    }

    private func eventData() -> EventData {
        update() ?? .empty
    }

    deinit {
        let interval = CMTime(seconds: Date().timeIntervalSince(lastEventDate), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let eventData = EventData(labels: eventData().labels, time: eventTime(after: interval), range: eventRange(after: interval))
        notify(.stop, eventData: eventData)
    }
}

extension CommandersActStreamingAnalytics {
    enum Heartbeat: String {
        case pos
        case uptime
    }

    func installHeartbeats() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.sendHeartbeat(.pos)
            }
            .store(in: &cancellables)
    }

    func uninstallHeartbeats() {
        cancellables = []
    }

    private func sendHeartbeat(_ heartbeat: Heartbeat) {
        Analytics.shared.sendCommandersActStreamingEvent(
            name: heartbeat.rawValue,
            labels: labels(eventData: eventData())
        )
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
}
