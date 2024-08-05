//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import UIKit

public final class MetricsTracker: PlayerItemTracker {
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    private var sessionId = UUID()
    private var stallDate: Date?
    private var metadata: Metadata?
    private var properties: PlayerProperties?
    private var stallDuration: TimeInterval = 0
    private var isStarted = false

    public var description: String? {
        "Monitoring: \(sessionId)"
    }

    public init(configuration: Void) {}

    public func enable(for player: AVPlayer) {}

    public func updateMetadata(to metadata: Metadata) {
        self.metadata = metadata
    }

    public func updateProperties(to properties: PlayerProperties) {
        self.properties = properties
    }

    public func updateMetricEvents(to events: [MetricEvent]) {
        switch events.last?.kind {
        case .resourceLoading:
            isStarted = true
            print("\(Self.self): \(String(decoding: startPayload(from: events)!, as: UTF8.self))")
        case .stall:
            stallDate = Date()
        case .resumeAfterStall:
            if let stallDate {
                stallDuration += Date().timeIntervalSince(stallDate)
            }
        case let .failure(error):
            if !isStarted {
                print("\(Self.self): \(String(decoding: startPayload(from: events)!, as: UTF8.self))")
            }
            print("\(Self.self): \(String(decoding: errorPayload(error: error, severity: .fatal)!, as: UTF8.self))")
        case let .warning(error):
            print("\(Self.self): \(String(decoding: errorPayload(error: error, severity: .warning)!, as: UTF8.self))")
        default:
            break
        }
    }

    public func disable(with properties: PlayerProperties) {
        print("\(Self.self): \(String(decoding: stopPayload(with: properties)!, as: UTF8.self))")
        sessionId = UUID()
        isStarted = false
    }
}

private extension MetricsTracker {
    static func bufferDuration(properties: PlayerProperties?) -> UInt? {
        guard let properties else { return nil }
        let loadedTimeRange = properties.loadedTimeRange
        return loadedTimeRange.isValid ? UInt(loadedTimeRange.duration.seconds * 1000) : 0
    }

    func startPayload(from events: [MetricEvent]) -> Data? {
        let payload = MetricPayload(
            sessionId: sessionId,
            eventName: .start,
            timestamp: Date().timeIntervalSince1970,
            data: MetricStartData(
                deviceId: UIDevice.current.identifierForVendor?.uuidString,
                deviceModel: Self.deviceModel,
                deviceType: Self.deviceType,
                screenWidth: UInt(UIScreen.main.nativeBounds.width),
                screenHeight: UInt(UIScreen.main.nativeBounds.height),
                osName: UIDevice.current.systemName,
                osVersion: UIDevice.current.systemVersion,
                playerName: "Pillarbox",
                playerPlatform: "Apple",
                playerVersion: Player.version,
                origin: Bundle.main.bundleIdentifier,
                mediaId: metadata?.mediaId,
                mediaSource: metadata?.mediaSource,
                timeMetrics: TimeMetrics(events: events)
            )
        )
        return try? Self.jsonEncoder.encode(payload)
    }

    func stopPayload(with properties: PlayerProperties) -> Data? {
        let metrics = properties.metrics()
        let payload = MetricPayload(
            sessionId: sessionId,
            eventName: .stop,
            timestamp: Date().timeIntervalSince1970,
            data: MetricEventData(
                url: metrics?.uri,
                bitrate: UInt(metrics?.indicatedBitrate ?? 0),
                bandwidth: UInt(metrics?.observedBitrate ?? 0),
                bufferDuration: Self.bufferDuration(properties: properties),
                stallCount: UInt(metrics?.total.numberOfStalls ?? 0),
                stallDuration: UInt(stallDuration),
                playbackDuration: UInt((metrics?.total.playbackDuration ?? 0) * 1000),
                playerPosition: UInt(properties.time().seconds * 1000)
            )
        )
        return try? Self.jsonEncoder.encode(payload)
    }

    func errorPayload(error: Error, severity: Severity) -> Data? {
        let error = error as NSError
        let playerPosition = properties?.time().seconds
        let payload = MetricErrorData(
            severity: severity,
            name: "\(error.domain)(\(error.code))",
            message: error.localizedDescription,
            playerPosition: playerPosition != nil ? UInt(playerPosition! * 1000) : nil
        )
        return try? Self.jsonEncoder.encode(payload)
    }
}

extension MetricsTracker {
    static let deviceType: String = {
        guard !ProcessInfo.processInfo.isRunningOnMac else { return "Computer" }
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "Phone"
        case .pad:
            return "Tablet"
        case .tv:
            return "TV"
        case .vision:
            return "Headset"
        default:
            return "Phone"
        }
    }()

    static let deviceModel: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine.0) { pointer in
            String(cString: pointer)
        }
    }()
}

public extension MetricsTracker {
    /// Metadata associated with the tracker.
    struct Metadata {
        let mediaId: String
        let mediaSource: String

        /// Creates metadata.
        public init(mediaId: String, mediaSource: String) {
            self.mediaId = mediaId
            self.mediaSource = mediaSource
        }
    }
}
