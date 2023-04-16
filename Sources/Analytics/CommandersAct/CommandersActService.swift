//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import TCServerSide_noIDFA

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

    private static func addCommonAdditionalProperties(to event: TCEvent) {
        if let captureIdentifier = AnalyticsRecorder.sessionIdentifier {
            event.addAdditionalProperty(AnalyticsRecorder.sessionIdentifierKey, withStringValue: captureIdentifier)
        }
    }

    func start(with configuration: Analytics.Configuration) {
        vendor = configuration.vendor
        guard let serverSide = ServerSide(siteID: 3666, andSourceKey: configuration.sourceKey) else { return }
        serverSide.addPermanentData("app_library_version", withValue: PackageInfo.version)
        serverSide.addPermanentData("navigation_app_site_name", withValue: configuration.site)
        serverSide.addPermanentData("navigation_device", withValue: Self.device())
        serverSide.enableRunningInBackground()
        self.serverSide = serverSide
    }

    func sendPageView(title: String, levels: [String]) {
        guard let serverSide, let event = TCPageViewEvent(type: title) else { return }
        event.addAdditionalProperty("navigation_property_type", withStringValue: "app")
        event.addAdditionalProperty("navigation_bu_distributer", withStringValue: vendor?.rawValue)
        levels.enumerated().forEach { index, level in
            guard index < 8, level.isValid else { return }
            event.addAdditionalProperty("navigation_level_\(index + 1)", withStringValue: level)
        }
        Self.addCommonAdditionalProperties(to: event)
        serverSide.execute(event)
    }

    func sendEvent(_ event: Event) {
        guard let serverSide, let customEvent = TCCustomEvent(name: "hidden_event") else { return }

        let eventProperties = [
            "event_title": event.name.isValid ? event.name : nil,
            "event_type": event.type.isValid ? event.type : nil,
            "event_value": event.value.isValid ? event.value : nil,
            "event_source": event.source.isValid ? event.source : nil,
            "event_value_1": event.extra1.isValid ? event.extra1 : nil,
            "event_value_2": event.extra2.isValid ? event.extra2 : nil,
            "event_value_3": event.extra3.isValid ? event.extra3 : nil,
            "event_value_4": event.extra4.isValid ? event.extra4 : nil,
            "event_value_5": event.extra5.isValid ? event.extra5 : nil
        ]

        eventProperties.forEach { key, value in
            customEvent.addAdditionalProperty(key, withStringValue: value)
        }

        Self.addCommonAdditionalProperties(to: customEvent)
        serverSide.execute(customEvent)
    }

    func sendStreamingEvent(name: String) {
        guard let serverSide, let customEvent = TCCustomEvent(name: name) else { return }
        Self.addCommonAdditionalProperties(to: customEvent)
        serverSide.execute(customEvent)
    }
}
