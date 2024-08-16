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

    private var session = TrackingSession()
    private var stallDate: Date?
    private var stallDuration: TimeInterval = 0

    private var cancellables = Set<AnyCancellable>()

    public var sessionIdentifier: String? {
        session.id
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
        switch events.last?.kind {
        case .resourceLoading:
            session.start()
            sendEvent(name: .start, data: startData(from: events))
            startHeartbeat()
        case .stall:
            stallDate = Date()
        case .resumeAfterStall:
            guard let stallDate else { break }
            stallDuration += Date().timeIntervalSince(stallDate)
        case let .failure(error):
            if !session.isStarted {
                session.start()
                sendEvent(name: .start, data: startData(from: events))
            }
            sendEvent(name: .error, data: errorData(error: error, severity: .fatal))
            session.stop()
        case let .warning(error):
            sendEvent(name: .error, data: errorData(error: error, severity: .warning))
        default:
            break
        }
    }

    public func disable(with properties: PlayerProperties) {
        defer {
            reset()
        }
        stopHeartbeat()
        if session.isStarted {
            sendEvent(name: .stop, data: statusData(from: properties))
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
    func startData(from events: [MetricEvent]) -> MetricStartData {
        MetricStartData(
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
    }

    func errorData(error: Error, severity: MetricErrorData.Severity) -> MetricErrorData {
        let error = error as NSError
        return MetricErrorData(
            message: error.localizedDescription,
            name: "\(error.domain)(\(error.code))",
            position: Self.position(from: properties),
            positionTimestamp: Self.positionTimestamp(from: properties),
            severity: severity,
            url: URL(string: properties?.metrics()?.uri)
        )
    }

    func statusData(from properties: PlayerProperties) -> MetricStatusData {
        let metrics = properties.metrics()
        return MetricStatusData(
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
        stallDuration = 0
        session.reset()
        stopwatch.reset()
    }
}

private extension MetricsTracker {
    static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    func sendEvent(name: EventName, data: some Encodable) {
        guard let sessionId = session.id else { return}

        let payload = MetricPayload(sessionId: sessionId, eventName: name, data: data)
        guard let httpBody = try? Self.jsonEncoder.encode(payload) else { return }

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
                sendEvent(name: .heartbeat, data: statusData(from: properties))
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
        return date.timestamp
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
