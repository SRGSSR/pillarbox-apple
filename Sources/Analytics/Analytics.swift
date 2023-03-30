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
        services.forEach { $0.start(with: configuration) }
    }
}
