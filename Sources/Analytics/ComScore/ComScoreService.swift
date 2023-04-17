//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import ComScore
import Foundation

struct ComScoreService {
    private var applicationVersion: String {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    func start(with configuration: Analytics.Configuration) {
        let publisherConfiguration = SCORPublisherConfiguration { builder in
            guard let builder else { return }
            builder.publisherId = "6036016"
            builder.secureTransmissionEnabled = true

            // See https://confluence.srg.beecollaboration.com/pages/viewpage.action?pageId=13188565
            // Coding Document for Video Players, section 4.4
            builder.httpRedirectCachingEnabled = false
        }
        if let comScoreConfiguration = SCORAnalytics.configuration() {
            comScoreConfiguration.addClient(with: publisherConfiguration)

            comScoreConfiguration.applicationVersion = applicationVersion
            comScoreConfiguration.usagePropertiesAutoUpdateMode = .foregroundAndBackground
            comScoreConfiguration.preventAdSupportUsage = true
            comScoreConfiguration.addPersistentLabels([
                "mp_brand": configuration.vendor.rawValue,
                "mp_v": applicationVersion
            ])
        }
        SCORAnalytics.start()
    }

    func sendPageView(title: String, levels: [String]) {
        var labels = ["ns_category": title]
        AnalyticsListener.capture(&labels)
        SCORAnalytics.notifyViewEvent(withLabels: labels)
    }
}
