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

    func start(with configuration: Analytics.Configuration) {
        vendor = configuration.vendor
        serverSide = ServerSide(siteID: 3666, andSourceKey: configuration.sourceKey)
        serverSide?.addPermanentData("app_library_version", withValue: PackageInfo.version)
        serverSide?.addPermanentData("navigation_app_site_name", withValue: configuration.site)
        serverSide?.addPermanentData("navigation_device", withValue: UIDevice.current.model)
        serverSide?.enableRunningInBackground()
    }

    func trackPageView(title: String, levels: [String], labels: Analytics.Labels?) {
        let event = TCPageViewEvent(type: title)

        event?.addAdditionalProperty("event_id", withStringValue: "screen")
        event?.addAdditionalProperty("navigation_property_type", withStringValue: "app")
        event?.addAdditionalProperty("content_title", withStringValue: title)
        event?.addAdditionalProperty("navigation_bu_distributer", withStringValue: vendor?.rawValue)
        levels.enumerated().forEach { index, level in
            guard index < 8 else { return }
            event?.addAdditionalProperty("navigation_level_\(index + 1)", withStringValue: level)
        }

        labels?.commandersAct.forEach { label in
            event?.addAdditionalProperty(label.key, withStringValue: label.value)
        }
        serverSide?.execute(event)
    }
}
