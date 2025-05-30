//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxCore
import TCServerSide

final class CommandersActService {
    private var serverSide: ServerSide?
    private var vendor: Vendor?

    private let lock = NSRecursiveLock()

    func start(with configuration: Analytics.Configuration) {
        withLock(lock) {
            vendor = configuration.vendor

            if let serverSide = ServerSide(siteID: 3666, andSourceKey: configuration.sourceKey.rawValue) {
                serverSide.addPermanentData("app_library_version", withValue: Analytics.version)
                serverSide.addPermanentData("navigation_app_site_name", withValue: configuration.appSiteName)
                serverSide.addPermanentData("navigation_device", withValue: Self.device)
                serverSide.enableRunningInBackground()
                serverSide.waitForUserAgent()
                self.serverSide = serverSide
            }

            // Use the legacy V4 identifier as unique identifier in V5.
            TCDevice.sharedInstance().sdkID = TCPredefinedVariables.sharedInstance().uniqueIdentifier()
            TCPredefinedVariables.sharedInstance().useLegacyUniqueIDForAnonymousID()
        }
    }

    func trackPageView(_ pageView: CommandersActPageView) {
        withLock(lock) {
            guard let serverSide, let event = TCPageViewEvent(type: pageView.type) else { return }
            pageView.labels.forEach { key, value in
                event.addAdditionalProperty(key, withStringValue: value)
            }
            event.pageName = pageView.name
            event.addNonBlankAdditionalProperty("navigation_property_type", withStringValue: "app")
            event.addNonBlankAdditionalProperty("content_bu_owner", withStringValue: vendor?.rawValue)
            pageView.levels.enumerated().forEach { index, level in
                guard index < 8 else { return }
                event.addNonBlankAdditionalProperty("navigation_level_\(index + 1)", withStringValue: level)
            }
            AnalyticsListener.capture(event)
            serverSide.execute(event)
        }
    }

    func sendEvent(_ event: CommandersActEvent) {
        withLock(lock) {
            guard let serverSide, let customEvent = TCCustomEvent(name: event.name) else { return }
            event.labels.forEach { key, value in
                customEvent.addNonBlankAdditionalProperty(key, withStringValue: value)
            }
            AnalyticsListener.capture(customEvent)
            serverSide.execute(customEvent)
        }
    }
}

extension CommandersActService {
    private static let device = {
        guard !ProcessInfo.processInfo.isRunningOnMac else { return "desktop" }
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "phone"
        case .pad:
            return "tablet"
        case .tv:
            return "tvbox"
        default:
            return "phone"
        }
    }()
}

extension TCAdditionalProperties {
    func addNonBlankAdditionalProperty(_ key: String, withStringValue value: String?) {
        guard let value, !value.isBlank else { return }
        addAdditionalProperty(key, withStringValue: value)
    }
}
