//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import TCServerSide_noIDFA

final class CommandersActService: AnalyticsService {
    private var serverSide: ServerSide?

    func start(with configuration: Analytics.Configuration) {
        serverSide = ServerSide(siteID: 3666, andSourceKey: configuration.sourceKey)
        serverSide?.addPermanentData("app_library_version", withValue: PackageInfo.version)
        serverSide?.addPermanentData("navigation_app_site_name", withValue: configuration.site)
        serverSide?.enableRunningInBackground()
    }

    func trackPageView(title: String, levels: [String], labels: Analytics.Labels?) {
        let event = TCPageViewEvent(type: title)
        labels?.commandersAct.forEach { label in
            event?.addAdditionalProperty(label.key, withStringValue: label.value)
        }
        serverSide?.execute(event)
    }
}
