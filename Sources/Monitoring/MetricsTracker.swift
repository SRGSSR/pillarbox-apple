//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer
import UIKit

public final class MetricsTracker: PlayerItemTracker {
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    private let sessionId = UUID()
    private var mediaSource: DateInterval?
    private weak var player: Player?
    private var metadata: Metadata?
    private var properties: PlayerProperties?
    private var stallDuration: UInt = 0

    public var description: String? {
        "Monitoring: \(sessionId)"
    }

    public init(configuration: Void) {}

    public func enable(for player: Player) {
        self.player = player
    }

    public func updateMetadata(with metadata: Metadata) {
        self.metadata = metadata
    }

    public func updateProperties(with properties: PlayerProperties) {
        self.properties = properties
    }

    public func receiveMetricEvent(_ event: MetricEvent) {
        switch event.kind {
        case let .assetLoading(dateInterval):
            mediaSource = dateInterval
        case let .resourceLoading(dateInterval):
            guard let mediaSource else { return }
            print("\(Self.self): \(String(decoding: startPayload(mediaSource: mediaSource, asset: dateInterval)!, as: UTF8.self))")
        case let .resumeAfterStall(dateInterval):
            stallDuration += UInt(dateInterval.duration * 1000)
        default:
            break
        }
    }

    public func disable() {
        print("\(Self.self): \(String(decoding: stopPayload()!, as: UTF8.self))")
    }
}

private extension MetricsTracker {
    static func bufferDuration(properties: PlayerProperties?) -> UInt? {
        guard let properties else { return nil }
        let loadedTimeRange = properties.loadedTimeRange
        return loadedTimeRange.isValid ? UInt(loadedTimeRange.duration.seconds * 1000) : 0
    }

    func startPayload(mediaSource: DateInterval, asset: DateInterval) -> Data? {
        let asset = UInt(round(asset.duration * 1000))
        let mediaSource = UInt(round(mediaSource.duration * 1000))
        let timeMetrics = TimeMetrics(mediaSource: mediaSource, asset: asset, total: mediaSource + asset)
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
                timeMetrics: timeMetrics
            )
        )
        return try? Self.jsonEncoder.encode(payload)
    }

    func stopPayload() -> Data? {
        let metrics = properties?.metrics()
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
                stallDuration: stallDuration,
                playbackDuration: UInt((metrics?.total.playbackDuration ?? 0) * 1000),
                playerPosition: UInt((player?.time.seconds ?? 0) * 1000)
            )
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
