//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore
import PillarboxPlayer
import UIKit

/// A tracker gathering metrics.
///
/// This tracker seamlessly integrates with Pillarbox monitoring platform.
public final class MetricsTracker: PlayerItemTracker {
    private let configuration: Configuration
    private let stopwatch = Stopwatch()

    private var metadata: Metadata?
    private var properties: PlayerProperties?

    private var sessionId = createSessionId()
    private var stallDate: Date?
    private var stallDuration: TimeInterval = 0
    private var isStarted = false

    private var cancellables = Set<AnyCancellable>()

    public var sessionIdentifier: String? {
        sessionId
    }

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

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
        guard let lastEvent = events.last else { return }
        switch lastEvent.kind {
        case .resourceLoading:
            isStarted = true
            send(payload: startPayload(from: events, at: lastEvent.date))
            startHeartbeat()
        case .stall:
            stallDate = Date()
        case .resumeAfterStall:
            guard let stallDate else { break }
            stallDuration += Date().timeIntervalSince(stallDate)
        case let .failure(error):
            if !isStarted {
                send(payload: startPayload(from: events, at: lastEvent.date))
            }
            send(payload: errorPayload(error: error, severity: .fatal, at: lastEvent.date))
            reset()
        case let .warning(error):
            send(payload: errorPayload(error: error, severity: .warning, at: lastEvent.date))
        default:
            break
        }
    }

    public func disable(with properties: PlayerProperties) {
        defer {
            reset()
        }
        stopHeartbeat()
        if isStarted {
            send(payload: statusEventPayload(for: .stop, with: properties, at: Date()))
        }
    }
}

public extension MetricsTracker {
    /// Configuration associated with the tracker.
    struct Configuration {
        let serviceUrl: URL
        let heartbeatInterval: TimeInterval

        /// Creates the configuration.
        ///
        /// - Parameters:
        ///   - serviceUrl: The URL service endpoint where data must be sent.
        ///   - heartbeatInterval: The interval between heartbeats, in seconds.
        public init(serviceUrl: URL, heartbeatInterval: TimeInterval = 30) {
            assert(heartbeatInterval >= 1)
            self.serviceUrl = serviceUrl
            self.heartbeatInterval = heartbeatInterval
        }
    }

    /// Metadata associated with the tracker.
    struct Metadata {
        let identifier: String?
        let metadataUrl: URL?
        let assetUrl: URL?

        /// Creates metadata.
        public init(identifier: String?, metadataUrl: URL?, assetUrl: URL?) {
            self.identifier = identifier
            self.metadataUrl = metadataUrl
            self.assetUrl = assetUrl
        }
    }
}

private extension MetricsTracker {
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    func startPayload(from events: [MetricEvent], at date: Date) -> some Encodable {
        MetricPayload(
            sessionId: sessionId,
            eventName: .start,
            timestamp: Self.timestamp(from: date),
            data: MetricStartData(
                device: .init(
                    id: Self.deviceId,
                    model: Self.deviceModel,
                    type: Self.deviceType
                ),
                os: .init(name: UIDevice.current.systemName, version: UIDevice.current.systemVersion),
                screen: .init(
                    width: Int(UIScreen.main.nativeBounds.width),
                    height: Int(UIScreen.main.nativeBounds.height)
                ),
                player: .init(name: "Pillarbox", platform: "Apple", version: Player.version),
                media: .init(
                    assetUrl: metadata?.assetUrl,
                    id: metadata?.identifier,
                    metadataUrl: metadata?.metadataUrl,
                    origin: Bundle.main.bundleIdentifier
                ),
                qoeMetrics: .init(events: events)
            )
        )
    }

    func errorPayload(error: Error, severity: MetricErrorData.Severity, at date: Date) -> some Encodable {
        let error = error as NSError
        return MetricPayload(
            sessionId: sessionId,
            eventName: .error,
            timestamp: Self.timestamp(from: date),
            data: MetricErrorData(
                message: error.localizedDescription,
                name: "\(error.domain)(\(error.code))",
                position: Self.position(from: properties),
                positionTimestamp: Self.positionTimestamp(from: properties),
                severity: severity,
                url: URL(string: properties?.metrics()?.uri)
            )
        )
    }

    func statusEventPayload(for eventName: EventName, with properties: PlayerProperties, at date: Date) -> some Encodable {
        let metrics = properties.metrics()
        return MetricPayload(
            sessionId: sessionId,
            eventName: eventName,
            timestamp: Self.timestamp(from: date),
            data: MetricStatusEventData(
                airplay: properties.isExternalPlaybackActive,
                bandwidth: metrics?.observedBitrate,
                bitrate: metrics?.indicatedBitrate,
                bufferedDuration: Self.bufferedDuration(from: properties),
                duration: Self.duration(from: properties),
                playbackDuration: stopwatch.time().toMilliseconds,
                position: Self.position(from: properties),
                positionTimestamp: Self.positionTimestamp(from: properties),
                stall: .init(
                    count: metrics?.total.numberOfStalls ?? 0,
                    duration: stallDuration.toMilliseconds
                ),
                streamType: Self.streamType(from: properties),
                url: metrics?.uri,
                vpn: Self.isUsingVirtualPrivateNetwork()
            )
        )
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
        sessionId = Self.createSessionId()
        stallDuration = 0
        isStarted = false
        stopwatch.reset()
    }
}

private extension MetricsTracker {
    func send(payload: Encodable) {
        guard let httpBody = try? Self.jsonEncoder.encode(payload) else {
            return
        }
        var request = URLRequest(url: configuration.serviceUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request).resume()

        MetricHitListener.capture(payload)
    }
}

private extension MetricsTracker {
    func startHeartbeat() {
        Timer.publish(every: configuration.heartbeatInterval, on: .main, in: .common)
            .autoconnect()
            .map { _ in }
            .prepend(())
            .sink { [weak self] _ in
                guard let self, let properties else { return }
                send(payload: statusEventPayload(for: .heartbeat, with: properties, at: Date()))
            }
            .store(in: &cancellables)
    }

    func stopHeartbeat() {
        cancellables = []
    }
}

private extension MetricsTracker {
    static let deviceId: String? = {
        UIDevice.current.identifierForVendor?.uuidString.lowercased()
    }()

    static let deviceModel: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine.0) { pointer in
            String(cString: pointer)
        }
    }()

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
}

private extension MetricsTracker {
    static func createSessionId() -> String {
        UUID().uuidString.lowercased()
    }

    static func streamType(from properties: PlayerProperties) -> String? {
        switch properties.streamType {
        case .unknown:
            return nil
        case .onDemand:
            return "On-demand"
        case .live, .dvr:
            return "Live"
        }
    }

    static func timestamp(from date: Date) -> Int {
        Int((date.timeIntervalSince1970 * 1000).rounded())
    }

    static func position(from properties: PlayerProperties?) -> Int? {
        guard let properties else { return nil }
        switch properties.streamType {
        case .unknown:
            return nil
        case .onDemand:
            return properties.time().toMilliseconds
        case .live:
            return 0
        case .dvr:
            return (properties.time() - properties.seekableTimeRange.start).toMilliseconds
        }
    }

    static func positionTimestamp(from properties: PlayerProperties?) -> Int? {
        guard let date = properties?.date() else { return nil }
        return timestamp(from: date)
    }

    static func bufferedDuration(from properties: PlayerProperties?) -> Int? {
        properties?.loadedTimeRange.duration.toMilliseconds
    }

    static func duration(from properties: PlayerProperties) -> Int? {
        properties.seekableTimeRange.duration.toMilliseconds
    }

    static func isUsingVirtualPrivateNetwork() -> Bool {
        // Source: https://blog.tarkalabs.com/the-ultimate-vpn-detection-guide-for-ios-and-android-313b521186cb
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
              let scopedSettings = proxySettings["__SCOPED__"] as? [String: Any] else {
            return false
        }
        return scopedSettings.keys.contains { key in
            key == "tap" || key == "ppp" || key.contains("tun") || key.contains("ipsec")
        }
    }
}
