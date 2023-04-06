//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import ComScore
import Foundation

struct ComScoreService: AnalyticsService {
    private var applicationVersion: String {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    func start(with configuration: Analytics.Configuration) {
        let publisherConfiguration = SCORPublisherConfiguration { builder in
            builder!.publisherId = "6036016"
            builder!.secureTransmissionEnabled = true

            // See https://confluence.srg.beecollaboration.com/pages/viewpage.action?pageId=13188565
            // Coding Document for Video Players, section 4.4
            builder!.httpRedirectCachingEnabled = false
        }
        let comScoreConfiguration = SCORAnalytics.configuration()!
        comScoreConfiguration.addClient(with: publisherConfiguration)

        comScoreConfiguration.applicationVersion = applicationVersion
        comScoreConfiguration.usagePropertiesAutoUpdateMode = .foregroundAndBackground
        comScoreConfiguration.preventAdSupportUsage = true
        comScoreConfiguration.addPersistentLabels([
            "mp_brand": configuration.vendor.rawValue,
            "mp_v": applicationVersion
        ])

        SCORAnalytics.start()
    }

    func trackPageView(title: String, levels: [String], labels: Analytics.Labels?) {
        let allLabels = ["ns_category": title].merging(labels?.comScore ?? [:]) { _, new in new }
        SCORAnalytics.notifyViewEvent(withLabels: allLabels)
    }
}
