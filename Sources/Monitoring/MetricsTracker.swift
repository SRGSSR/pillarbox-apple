//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer
import UIKit

public final class MetricsTracker: PlayerItemTracker {
    private let sessionId = UUID()
    private var mediaSource: UInt?
    private var metadata: Metadata?

    public init(configuration: Void) {}

    public func enable(for player: Player) {}

    public func updateMetadata(with metadata: Metadata) {
        self.metadata = metadata
    }

    public func updateProperties(with properties: PlayerProperties) {}

    public func receiveMetricEvent(_ event: MetricEvent) {
        switch event.kind {
        case let .assetLoading(dateInterval):
            mediaSource = UInt(round(dateInterval.duration * 1000))
        case let .resourceLoading(dateInterval):
            guard let mediaSource else { return }
            let asset = UInt(round(dateInterval.duration * 1000))
            let timeMetrics = TimeMetrics(mediaSource: mediaSource, asset: asset, total: mediaSource + asset)
            let payload = MetricPayload(
                sessionId: sessionId,
                eventName: .start,
                timestamp: Date().timeIntervalSince1970,
                data: MetricStartData(
                    deviceId: UIDevice.current.identifierForVendor?.uuidString,
                    deviceModel: Self.deviceModel,
                    deviceType: Self.deviceType,
                    screenWidth: UInt(UIScreen.main.bounds.width),
                    screenHeight: UInt(UIScreen.main.bounds.height),
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
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try? encoder.encode(payload)
            print("--> \(String(decoding: data!, as: UTF8.self))")
        case let .failure(error):
            print(error)
        default:
            break
        }
    }

    public func disable() {}
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
