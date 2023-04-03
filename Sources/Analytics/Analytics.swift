//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public class Analytics {
    public struct Configuration {
        let vendor: Vendor
        let sourceKey: String
        let site: String

        public init(vendor: Vendor, sourceKey: String, site: String) {
            self.vendor = vendor
            self.sourceKey = sourceKey
            self.site = site
        }
    }

    public struct Labels {
        let comScore: [String: String]
        let commandersAct: [String: String]

        public init(comScore: [String: String], commandersAct: [String: String]) {
            self.comScore = comScore
            self.commandersAct = commandersAct
        }

        public func merging(_ other: Self) -> Self {
            .init(
                comScore: comScore.merging(other.comScore) { _, new in new },
                commandersAct: commandersAct.merging(other.commandersAct) { _, new in new }
            )
        }
    }

    public static var shared: Analytics = {
        .init()
    }()

    private var configuration: Configuration?
    private let services: [any AnalyticsService] = [ComScoreService(), CommandersActService()]

    private init() {}

    public func start(with configuration: Configuration) throws {
        guard self.configuration == nil else {
            throw AnalyticsError.alreadyStarted
        }
        self.configuration = configuration
        services.forEach { $0.start(with: configuration) }
    }

    public func trackPageView(title: String, levels: [String] = [], labels: Labels? = nil) {
        services.forEach { $0.trackPageView(title: title, levels: levels, labels: labels) }
    }
}
