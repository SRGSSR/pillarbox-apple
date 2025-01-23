//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A single entry-point for analytics conforming to the SRG SSR standards.
///
/// SRG SSR applications must use this singleton to gather analytics. These include:
///
/// - Page views: Which views are presented to the user.
/// - Events: Arbitrary events which need to be recorded (e.g., user interaction with a button).
/// - Streaming: Streaming analytics collected with standard `PlayerItemTracker` implementations.
///
/// Before analytics can be gathered the singleton must be started with a configuration suitable for your application.
public class Analytics {
    /// A configuration for analytics.
    ///
    /// Please contact our SRG SSR Digital Analytics team (ADI) to obtain configuration parameters suitable for your
    /// application.
    public struct Configuration {
        let vendor: Vendor
        let sourceKey: String
        let appSiteName: String

        /// Creates an analytics configuration.
        ///
        /// Contact the ADI team to get configuration parameters for your app.
        ///
        /// - Parameters:
        ///   - vendor: The vendor which the application belongs to.
        ///   - sourceKey: The source key. Production apps should use `.productionSourceKey` while apps in development
        ///     should use `.developmentSourceKey`.
        ///   - appSiteName: The app/site name.
        public init(vendor: Vendor, sourceKey: String, appSiteName: String) {
            self.vendor = vendor
            self.sourceKey = sourceKey
            self.appSiteName = appSiteName
        }
    }

    /// The singleton instance.
    public static let shared = Analytics()

    /// The analytics version.
    public static let version = PackageInfo.version

    var comScoreGlobals: ComScoreGlobals? {
        dataSource?.comScoreGlobals
    }

    private var configuration: Configuration?

    private let comScoreService = ComScoreService()
    private let commandersActService = CommandersActService()

    private weak var dataSource: AnalyticsDataSource?

    private init() {}

    /// Starts analytics with the specified configuration.
    ///
    /// - Parameters:
    ///   - configuration: The configuration to use.
    ///   - dataSource: The data source to use.
    ///
    /// This method must be called from your `UIApplicationDelegate.application(_:didFinishLaunchingWithOptions:)`
    /// delegate method implementation, otherwise the behavior is undefined.
    ///
    /// The method throws if called more than once.
    public func start(with configuration: Configuration, dataSource: AnalyticsDataSource? = nil) throws {
        guard self.configuration == nil else {
            throw AnalyticsError.alreadyStarted
        }
        self.configuration = configuration
        self.dataSource = dataSource

        UIViewController.setupViewControllerTracking()

        comScoreService.start(with: configuration, globals: dataSource?.comScoreGlobals)
        commandersActService.start(with: configuration)
    }

    /// Tracks a page view.
    ///
    /// - Parameter commandersActPageView: The Commanders Act page view data.
    public func trackPageView(commandersAct commandersActPageView: CommandersActPageView) {
        commandersActService.trackPageView(
            commandersActPageView.merging(globals: dataSource?.commandersActGlobals)
        )
    }

    /// Sends an event.
    /// 
    /// - Parameter commandersActEvent: The Commanders Act event data.
    public func sendEvent(commandersAct commandersActEvent: CommandersActEvent) {
        commandersActService.sendEvent(
            commandersActEvent.merging(globals: dataSource?.commandersActGlobals)
        )
    }
}

public extension String {
    /// The source key for apps in production.
    static let productionSourceKey = "1b30366c-9e8d-4720-8b12-4165f468f9ae"

    /// The source key for apps in development.
    static let developmentSourceKey = "39ae8f94-595c-4ca4-81f7-fb7748bd3f04"
}
