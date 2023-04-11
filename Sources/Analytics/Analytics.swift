//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Gathers analytics according to SRG SSR standards. Used as a singleton which must be started using `start(with:)`
/// before use.
public class Analytics {
    /// Analytics configuration.
    public struct Configuration {
        let vendor: Vendor
        let sourceKey: String
        let site: String

        /// Configure analytics. `sourceKey` and `site` must be obtained from the team responsible of measurements for
        /// your application.
        /// - Parameters:
        ///   - vendor: The vendor which the application belongs to.
        ///   - sourceKey: The source key.
        ///   - site: The site name.
        public init(vendor: Vendor, sourceKey: String, site: String) {
            self.vendor = vendor
            self.sourceKey = sourceKey
            self.site = site
        }
    }

    /// Information sent with analytics events.
    struct Labels {
        /// comScore-specific information.
        let comScore: [String: String]

        /// Commanders Act-specific information.
        let commandersAct: [String: String]

        /// Merge labels together.
        /// - Parameter other: The other labels which must be merged into the receiver.
        /// - Returns: The merged labels.
        func merging(_ other: Self) -> Self {
            .init(
                comScore: comScore.merging(other.comScore) { _, new in new },
                commandersAct: commandersAct.merging(other.commandersAct) { _, new in new }
            )
        }
    }

    /// The singleton instance.
    public static var shared = Analytics()

    private var configuration: Configuration?
    private let services: [any AnalyticsService] = [ComScoreService(), CommandersActService()]

    private init() {}

    /// Start analytics with the specified configuration. Must be called from your
    /// `UIApplicationDelegate.application(_:didFinishLaunchingWithOptions:)` delegate method. Throws if started more
    ///  than once.
    /// - Parameter configuration: The configuration to use.
    public func start(with configuration: Configuration) throws {
        guard self.configuration == nil else {
            throw AnalyticsError.alreadyStarted
        }
        self.configuration = configuration
        services.forEach { $0.start(with: configuration) }
    }

    /// Record a page view event.
    /// - Parameters:
    ///   - title: The page title.
    ///   - levels: The page levels.
    public func trackPageView(title: String, levels: [String] = []) {
        trackPageView(title: title, levels: levels, labels: nil)
    }

    func trackPageView(title: String, levels: [String], labels: Labels?) {
        services.forEach { $0.trackPageView(title: title, levels: levels, labels: labels) }
    }
}
