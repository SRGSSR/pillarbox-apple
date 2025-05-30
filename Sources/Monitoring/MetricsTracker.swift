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

/// A tracker gathering metrics for Pillarbox monitoring platform.
public final class MetricsTracker: PlayerItemTracker {
    private var metadata: Metadata?
    private var properties: TrackerProperties?

    private var session = TrackingSession()
    private var stallDate: Date?
    private var stallDuration: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()

    private let configuration: Configuration
    private let stopwatch = Stopwatch()
    private let lock = NSRecursiveLock()

    // swiftlint:disable:next missing_docs
    public var sessionIdentifier: String? {
        withLock(lock) {
            session.id
        }
    }

    // swiftlint:disable:next missing_docs
    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    // swiftlint:disable:next missing_docs
    public func enable(for player: AVPlayer) {}

    // swiftlint:disable:next missing_docs
    public func updateMetadata(to metadata: Metadata) {
        withLock(lock) {
            self.metadata = metadata
        }
    }

    // swiftlint:disable:next missing_docs
    public func updateProperties(to properties: TrackerProperties) {
        withLock(lock) {
            self.properties = properties
            updateStopwatch(with: properties)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity missing_docs
    public func updateMetricEvents(to events: [MetricEvent]) {
        withLock(lock) {
            switch events.last?.kind {
            case .asset:
                reset(with: properties)
                session.start()
                sendEvent(name: .start, data: startData(from: events))
                startHeartbeat()
            case .stall:
                stallDate = .now
            case .resumeAfterStall:
                guard let stallDate else { break }
                stallDuration += Date.now.timeIntervalSince(stallDate)
            case let .failure(error):
                if !session.isStarted {
                    session.start()
                    sendEvent(name: .start, data: startData(from: events))
                }
                sendEvent(name: .error, data: errorData(from: error))
                session.stop()
            default:
                break
            }
        }
    }

    // swiftlint:disable:next missing_docs
    public func disable(with properties: TrackerProperties) {
        withLock(lock) {
            reset(with: properties)
        }
    }

    private func sendHeartbeat() {
        withLock(lock) {
            guard let properties else { return }
            sendEvent(name: .heartbeat, data: statusData(from: properties))
        }
    }
}

public extension MetricsTracker {
    /// Configuration associated with the tracker.
    struct Configuration {
        let identifier: String
        let serviceUrl: URL
        let heartbeatInterval: TimeInterval

        /// Creates the configuration.
        ///
        /// - Parameters:
        ///   - identifier: An identifier for the content.
        ///   - serviceUrl: The URL service endpoint where data must be sent.
        ///   - heartbeatInterval: The interval between heartbeats, in seconds.
        public init(identifier: String, serviceUrl: URL, heartbeatInterval: TimeInterval = 30) {
            assert(heartbeatInterval >= 1)
            self.identifier = identifier
            self.serviceUrl = serviceUrl
            self.heartbeatInterval = heartbeatInterval
        }
    }

    /// Metadata associated with the tracker.
    struct Metadata {
        let metadataUrl: URL?
        let assetUrl: URL?

        /// Creates metadata.
        ///
        /// - Parameters:
        ///   - metadataUrl: The URL where metadata has been fetched.
        ///   - assetUrl: The URL of the asset being played.
        public init(metadataUrl: URL? = nil, assetUrl: URL? = nil) {
            self.metadataUrl = metadataUrl
            self.assetUrl = assetUrl
        }
    }
}

private extension MetricsTracker {
    func startData(from events: [MetricEvent]) -> MetricStartData {
        MetricStartData(
            application: .init(
                id: Self.applicationId,
                version: Self.applicationVersion
            ),
            device: .init(
                id: Self.deviceId,
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
                assetUrl: metadata?.assetUrl,
                id: configuration.identifier,
                metadataUrl: metadata?.metadataUrl
            ),
            qoeTimings: .init(events: events),
            qosTimings: .init(events: events)
        )
    }

    func errorData(from error: Error) -> MetricErrorData {
        let error = error as NSError
        return MetricErrorData(
            audio: Self.languageCode(from: properties, for: .audible),
            message: error.localizedDescription,
            name: "\(error.domain)(\(error.code))",
            position: Self.position(from: properties),
            positionTimestamp: Self.positionTimestamp(from: properties),
            subtitles: Self.languageCode(from: properties, for: .legible),
            url: URL(string: properties?.metrics?.uri),
            vpn: Self.isUsingVirtualPrivateNetwork()
        )
    }

    func statusData(from properties: TrackerProperties) -> MetricStatusData {
        let metrics = properties.metrics
        return MetricStatusData(
            airplay: properties.isExternalPlaybackActive,
            audio: Self.languageCode(from: properties, for: .audible),
            bandwidth: metrics?.observedBitrate,
            bitrate: metrics?.indicatedBitrate,
            bufferedDuration: Self.bufferedDuration(from: properties),
            duration: Self.duration(from: properties),
            frameDrops: metrics?.total.numberOfDroppedVideoFrames,
            playbackDuration: stopwatch.time().toMilliseconds,
            position: Self.position(from: properties),
            positionTimestamp: Self.positionTimestamp(from: properties),
            stall: .init(
                count: metrics?.total.numberOfStalls ?? 0,
                duration: stallDuration.toMilliseconds
            ),
            streamType: Self.streamType(from: properties),
            subtitles: Self.languageCode(from: properties, for: .legible),
            url: metrics?.uri
        )
    }

    func updateStopwatch(with properties: TrackerProperties) {
        if properties.playbackState == .playing && !properties.isBuffering {
            stopwatch.start()
        }
        else {
            stopwatch.stop()
        }
    }

    func reset(with properties: TrackerProperties?) {
        defer {
            stallDuration = 0
            session.reset()
            stopwatch.reset()
        }
        stopHeartbeat()
        if let properties, session.isStarted {
            sendEvent(name: .stop, data: statusData(from: properties))
        }
    }
}

private extension MetricsTracker {
    static let jsonEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    func sendEvent(name: EventName, data: some Encodable) {
        guard let sessionId = session.id else { return }

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
    static let applicationId = Bundle.main.bundleIdentifier
    static let applicationVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
}

private extension MetricsTracker {
    func startHeartbeat() {
        Timer.publish(every: configuration.heartbeatInterval, on: .main, in: .common)
            .autoconnect()
            .map { _ in }
            .prepend(())
            .sink { [weak self] _ in
                self?.sendHeartbeat()
            }
            .store(in: &cancellables)
    }

    func stopHeartbeat() {
        cancellables = []
    }
}

private extension MetricsTracker {
    static let deviceId = UIDevice.current.identifierForVendor?.uuidString.lowercased()

    static let deviceModel = {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine.0) { pointer in
            String(cString: pointer)
        }
    }()

    static let deviceType = {
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
    static func streamType(from properties: TrackerProperties) -> String? {
        switch properties.streamType {
        case .unknown:
            return nil
        case .onDemand:
            return "On-demand"
        case .live, .dvr:
            return "Live"
        }
    }

    static func position(from properties: TrackerProperties?) -> Int? {
        guard let properties else { return nil }
        switch properties.streamType {
        case .unknown:
            return nil
        case .onDemand:
            return properties.time.toMilliseconds
        case .live:
            return 0
        case .dvr:
            return (properties.time - properties.seekableTimeRange.start).toMilliseconds
        }
    }

    static func positionTimestamp(from properties: TrackerProperties?) -> Int? {
        guard let date = properties?.date else { return nil }
        return date.timestamp
    }

    static func bufferedDuration(from properties: TrackerProperties?) -> Int? {
        properties?.loadedTimeRange.duration.toMilliseconds
    }

    static func duration(from properties: TrackerProperties) -> Int? {
        properties.seekableTimeRange.duration.toMilliseconds
    }

    static func languageCode(from properties: TrackerProperties?, for characteristic: AVMediaCharacteristic) -> String? {
        if case let .on(option) = properties?.currentMediaOption(for: characteristic) {
            return languageCode(from: option)
        }
        else {
            return nil
        }
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

    private static func languageCode(from option: AVMediaSelectionOption?) -> String? {
        option?.locale?.language.languageCode?.identifier
    }
}
