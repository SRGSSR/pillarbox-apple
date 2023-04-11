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

    /// Record an event.
    /// - Parameters:
    ///   - name: The event name.
    ///   - type: The event type.
    ///   - value: The event value.
    ///   - source: The event source.
    ///   - extra1: The event extra1.
    ///   - extra2: The event extra2.
    ///   - extra3: The event extra3.
    ///   - extra4: The event extra4.
    ///   - extra5: The event extra5.
    public func trackEvent(
        name: String = "",
        type: String = "",
        value: String = "",
        source: String = "",
        extra1: String = "",
        extra2: String = "",
        extra3: String = "",
        extra4: String = "",
        extra5: String = ""
    ) {
        services.forEach { service in
            service.trackEvent(
                name: name,
                type: type,
                value: value,
                source: source,
                extra1: extra1,
                extra2: extra2,
                extra3: extra3,
                extra4: extra4,
                extra5: extra5
            )
        }
    }

    func trackPageView(title: String, levels: [String], labels: Labels?) {
        services.forEach { $0.trackPageView(title: title, levels: levels, labels: labels) }
    }
}
