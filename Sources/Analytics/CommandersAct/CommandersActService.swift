//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import TCCore
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
        TCDebug.setDebugLevel(TCLogLevel_None)
        guard let serverSide = ServerSide(siteID: 3666, andSourceKey: configuration.sourceKey) else { return }
        serverSide.addPermanentData("app_library_version", withValue: PackageInfo.version)
        serverSide.addPermanentData("navigation_app_site_name", withValue: configuration.appSiteName)
        serverSide.addPermanentData("navigation_device", withValue: Self.device())
        serverSide.enableRunningInBackground()
        self.serverSide = serverSide
    }

    func trackPageView(_ pageView: CommandersActPageView) {
        guard let serverSide, let event = TCPageViewEvent(type: pageView.type) else { return }
        event.addNonBlankAdditionalProperty("content_title", withStringValue: pageView.title)
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

        let eventProperties = [
            "event_type": event.type,
            "event_value": event.value,
            "event_source": event.source,
            "event_value_1": event.extra1,
            "event_value_2": event.extra2,
            "event_value_3": event.extra3,
            "event_value_4": event.extra4,
            "event_value_5": event.extra5
        ]

        eventProperties.forEach { key, value in
            customEvent.addNonBlankAdditionalProperty(key, withStringValue: value)
        }

        AnalyticsListener.capture(customEvent)
        serverSide.execute(customEvent)
    }

    func sendStreamingEvent(_ event: CommandersActStreamingEvent) {
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
