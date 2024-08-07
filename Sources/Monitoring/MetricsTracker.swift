//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxCore
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
    private let stopwatch = Stopwatch()
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
        updateStopwatch(with: properties)
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func updateMetricEvents(to events: [MetricEvent]) {
        switch events.last?.kind {
        case .resourceLoading:
            isStarted = true
            if let data = startPayload(from: events) {
                Self.send(data: data)
            }
        case .stall:
            stallDate = Date()
        case .resumeAfterStall:
            guard let stallDate else { break }
            stallDuration += Date().timeIntervalSince(stallDate)
        case let .failure(error):
            if !isStarted {
                if let data = startPayload(from: events) {
                    Self.send(data: data)
                }
            }
            if let data = errorPayload(error: error, severity: .fatal) {
                Self.send(data: data)
            }
        case let .warning(error):
            if let data = errorPayload(error: error, severity: .warning) {
                Self.send(data: data)
            }
        default:
            break
        }
    }

    public func disable(with properties: PlayerProperties) {
        defer {
            reset()
        }
        if let data = stopPayload(with: properties) {
            Self.send(data: data)
        }
    }
}

public extension MetricsTracker {
    /// Metadata associated with the tracker.
    struct Metadata {
        let id: String?
        let metadataUrl: URL?
        let assetUrl: URL?

        /// Creates metadata.
        public init(id: String?, metadataUrl: URL?, assetUrl: URL?) {
            self.id = id
            self.metadataUrl = metadataUrl
            self.assetUrl = assetUrl
        }
    }
}

private extension MetricsTracker {
    static func bufferDuration(properties: PlayerProperties?) -> Int? {
        properties?.loadedTimeRange.duration.toMilliseconds
    }

    func startPayload(from events: [MetricEvent]) -> Data? {
        let payload = MetricPayload(
            sessionId: sessionId,
            eventName: .start,
            timestamp: Date().timeIntervalSince1970,
            data: MetricStartData(
                device: .init(
                    id: UIDevice.current.identifierForVendor?.uuidString,
                    model: Self.deviceModel,
                    type: Self.deviceType
                ),
                os: .init(
                    name: UIDevice.current.systemName,
                    version: UIDevice.current.systemVersion
                ),
                screen: .init(
                    width: Int(UIScreen.main.nativeBounds.width),
                    height: Int(UIScreen.main.nativeBounds.height)
                ),
                player: .init(
                    name: "Pillarbox",
                    platform: "Apple",
                    version: Player.version
                ),
                media: .init(
                    id: metadata?.id,
                    metadataUrl: metadata?.metadataUrl,
                    assetUrl: metadata?.assetUrl,
                    origin: Bundle.main.bundleIdentifier
                ),
                timeMetrics: .init(events: events)
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
                bitrate: metrics?.indicatedBitrate?.toBytes,
                bandwidth: metrics?.observedBitrate?.toBytes,
                bufferDuration: Self.bufferDuration(properties: properties),
                stallCount: metrics?.total.numberOfStalls,
                stallDuration: stallDuration.toMilliseconds,
                playbackDuration: stopwatch.time().toMilliseconds,
                playerPosition: properties.time().toMilliseconds
            )
        )
        return try? Self.jsonEncoder.encode(payload)
    }

    func errorPayload(error: Error, severity: MetricErrorData.Severity) -> Data? {
        let error = error as NSError
        let payload = MetricPayload(
            sessionId: sessionId,
            eventName: .error,
            timestamp: Date().timeIntervalSince1970,
            data: MetricErrorData(
                severity: severity,
                name: "\(error.domain)(\(error.code))",
                message: error.localizedDescription,
                playerPosition: properties?.time().toMilliseconds
            )
        )
        return try? Self.jsonEncoder.encode(payload)
    }

    func updateStopwatch(with properties: PlayerProperties) {
        if properties.playbackState == .playing && !properties.isBuffering {
            stopwatch.start()
        }
        else {
            stopwatch.stop()
        }
    }

    func reset() {
        sessionId = UUID()
        stallDuration = 0
        isStarted = false
        stopwatch.reset()
    }
}

private extension MetricsTracker {
    static func send(data: Data) {
        var request = URLRequest(url: .init(string: "https://echo.free.beeceptor.com")!)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request).resume()
    }
}

private extension MetricsTracker {
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
