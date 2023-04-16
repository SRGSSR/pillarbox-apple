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
            guard index < 8, !level.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            event.addAdditionalProperty("navigation_level_\(index + 1)", withStringValue: level)
        }
        Self.addCommonAdditionalProperties(to: event)
        serverSide.execute(event)
    }

    func sendEvent(_ event: Event) {
        guard let serverSide, let customEvent = TCCustomEvent(name: "hidden_event") else { return }
        customEvent.addAdditionalProperty("event_title", withStringValue: event.name)
        customEvent.addAdditionalProperty("event_type", withStringValue: event.type)
        customEvent.addAdditionalProperty("event_value", withStringValue: event.value)
        customEvent.addAdditionalProperty("event_source", withStringValue: event.source)
        customEvent.addAdditionalProperty("event_value_1", withStringValue: event.extra1)
        customEvent.addAdditionalProperty("event_value_2", withStringValue: event.extra2)
        customEvent.addAdditionalProperty("event_value_3", withStringValue: event.extra3)
        customEvent.addAdditionalProperty("event_value_4", withStringValue: event.extra4)
        customEvent.addAdditionalProperty("event_value_5", withStringValue: event.extra5)
        Self.addCommonAdditionalProperties(to: customEvent)
        serverSide.execute(customEvent)
    }

    func sendStreamingEvent(name: String) {
        guard let serverSide, let customEvent = TCCustomEvent(name: name) else { return }
        Self.addCommonAdditionalProperties(to: customEvent)
        serverSide.execute(customEvent)
    }
}
