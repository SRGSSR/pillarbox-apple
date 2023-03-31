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

            // See https://confluence.srg.beecollaboration.com/display/INTFORSCHUNG/ComScore+-+Media+Metrix+Report
            // Coding Document for Video Players, page 16
            builder!.httpRedirectCachingEnabled = false
        }
        let comScoreConfiguration = SCORAnalytics.configuration()!
        comScoreConfiguration.addClient(with: publisherConfiguration)

        comScoreConfiguration.applicationVersion = applicationVersion
        comScoreConfiguration.usagePropertiesAutoUpdateMode = .foregroundAndBackground
        comScoreConfiguration.preventAdSupportUsage = true

        SCORAnalytics.start()
    }

    func trackPageView(title: String, levels: [String], labels: [String: String]) {
        let allLabels = ["name": title].merging(labels, uniquingKeysWith: { _, new in new })
        SCORAnalytics.notifyViewEvent(withLabels: allLabels)
    }
}
