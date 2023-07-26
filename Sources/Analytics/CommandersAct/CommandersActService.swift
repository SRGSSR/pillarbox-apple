//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import TCServerSide

final class CommandersActService {
    private var serverSide: ServerSide?
    private var vendor: Vendor?

    private static func device() -> String {
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
    }

    func start(with configuration: Analytics.Configuration) {
        vendor = configuration.vendor
        guard let serverSide = ServerSide(siteID: 3666, andSourceKey: configuration.sourceKey) else { return }
        serverSide.addPermanentData("app_library_version", withValue: PackageInfo.version)
        serverSide.addPermanentData("navigation_app_site_name", withValue: configuration.appSiteName)
        serverSide.addPermanentData("navigation_device", withValue: Self.device())
        serverSide.enableRunningInBackground()
        self.serverSide = serverSide
    }

    func trackPageView(_ pageView: CommandersActPageView) {
        guard let serverSide, let event = TCPageViewEvent(type: pageView.type) else { return }
        pageView.labels.forEach { key, value in
            event.addAdditionalProperty(key, withStringValue: value)
        }
        event.addNonBlankAdditionalProperty("content_title", withStringValue: pageView.name)
        event.addNonBlankAdditionalProperty("navigation_property_type", withStringValue: "app")
        event.addNonBlankAdditionalProperty("navigation_bu_distributer", withStringValue: vendor?.rawValue)
        pageView.levels.enumerated().forEach { index, level in
            guard index < 8 else { return }
            event.addNonBlankAdditionalProperty("navigation_level_\(index + 1)", withStringValue: level)
        }
        AnalyticsListener.capture(event)
        serverSide.execute(event)
    }

    func sendEvent(_ event: CommandersActEvent) {
        guard let serverSide, let customEvent = TCCustomEvent(name: event.name) else { return }
        event.labels.forEach { key, value in
            customEvent.addNonBlankAdditionalProperty(key, withStringValue: value)
        }
        AnalyticsListener.capture(customEvent)
        serverSide.execute(customEvent)
    }
}

extension TCAdditionalProperties {
    func addNonBlankAdditionalProperty(_ key: String, withStringValue value: String?) {
        guard let value, !value.isBlank else { return }
        addAdditionalProperty(key, withStringValue: value)
    }
}
