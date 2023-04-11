//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import TCServerSide_noIDFA

final class CommandersActService: AnalyticsService {
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
        serverSide.addPermanentData("navigation_app_site_name", withValue: configuration.site)
        serverSide.addPermanentData("navigation_device", withValue: Self.device())
        serverSide.enableRunningInBackground()
        self.serverSide = serverSide
    }

    func sendPageView(title: String, levels: [String], labels: Labels?) {
        guard let serverSide, let event = TCPageViewEvent(type: title) else { return }

        event.addAdditionalProperty("navigation_property_type", withStringValue: "app")
        event.addAdditionalProperty("navigation_bu_distributer", withStringValue: vendor?.rawValue)
        levels.enumerated().forEach { index, level in
            guard index < 8 else { return }
            event.addAdditionalProperty("navigation_level_\(index + 1)", withStringValue: level)
        }

        labels?.commandersAct.forEach { label in
            event.addAdditionalProperty(label.key, withStringValue: label.value)
        }
        serverSide.execute(event)
    }

    // swiftlint:disable:next function_parameter_count
    func sendEvent(
        name: String,
        type: String,
        value: String,
        source: String,
        extra1: String,
        extra2: String,
        extra3: String,
        extra4: String,
        extra5: String,
        labels: Labels?
    ) {
        guard let serverSide, let event = TCCustomEvent(name: name) else { return }
        event.addAdditionalProperty("event_type", withStringValue: type)
        event.addAdditionalProperty("event_value", withStringValue: value)
        event.addAdditionalProperty("event_source", withStringValue: source)
        event.addAdditionalProperty("event_value_1", withStringValue: extra1)
        event.addAdditionalProperty("event_value_2", withStringValue: extra2)
        event.addAdditionalProperty("event_value_3", withStringValue: extra3)
        event.addAdditionalProperty("event_value_4", withStringValue: extra4)
        event.addAdditionalProperty("event_value_5", withStringValue: extra5)

        labels?.commandersAct.forEach { label in
            event.addAdditionalProperty(label.key, withStringValue: label.value)
        }

        serverSide.execute(event)
    }
}
