//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import UIKit

/// A single entry-point for analytics conforming to the SRG SSR standards.
///
/// SRG SSR applications must use this singleton to gather analytics. These include:
///
/// - Page views: Which views are presented to the user.
/// - Events: Arbitrary events which need to be recorded (e.g. user interaction with a button).
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
        ///   - sourceKey: The source key.
        ///   - appSiteName: The app/site name.
        public init(vendor: Vendor, sourceKey: String, appSiteName: String) {
            self.vendor = vendor
            self.sourceKey = sourceKey
            self.appSiteName = appSiteName
        }
    }

    /// The singleton instance.
    public static var shared = Analytics()

    private var configuration: Configuration?

    private let comScoreService = ComScoreService()
    private let commandersActService = CommandersActService()

    private init() {}

    /// Starts analytics with the specified configuration.
    ///
    /// - Parameter configuration: The configuration to use.
    ///
    /// This method must be called from your `UIApplicationDelegate.application(_:didFinishLaunchingWithOptions:)`
    /// delegate method implementation, otherwise the behavior is undefined.
    ///
    /// The method throws if called more than once.
    public func start(with configuration: Configuration) throws {
        guard self.configuration == nil else {
            throw AnalyticsError.alreadyStarted
        }
        self.configuration = configuration

        UIViewController.setupViewControllerTracking()

        comScoreService.start(with: configuration)
        commandersActService.start(with: configuration)
    }

    /// Tracks a page view.
    ///
    /// - Parameters:
    ///   - title: The page title.
    ///   - levels: The page levels.
    public func trackPageView(title: String, levels: [String] = []) {
        assert(!title.isBlank, "A title is required")
        comScoreService.trackPageView(title: title, levels: levels)
        commandersActService.trackPageView(title: title, levels: levels)
    }

    /// Sends an event.
    /// 
    /// - Parameters:
    ///   - name: The event name.
    ///   - type: The event type.
    ///   - value: The event value.
    ///   - source: The event source.
    ///   - extra1: Extra information associated with the event.
    ///   - extra2: Extra information associated with the event.
    ///   - extra3: Extra information associated with the event.
    ///   - extra4: Extra information associated with the event.
    ///   - extra5: Extra information associated with the event.
    public func sendEvent(
        name: String,
        type: String = "",
        value: String = "",
        source: String = "",
        extra1: String = "",
        extra2: String = "",
        extra3: String = "",
        extra4: String = "",
        extra5: String = ""
    ) {
        assert(!name.isBlank, "A name is required")
        let event = Event(
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
        commandersActService.sendEvent(event)
    }

    func sendCommandersActStreamingEvent(name: String, labels: [String: String]) {
        assert(!name.isEmpty, "A name is required")
        commandersActService.sendStreamingEvent(name: name, labels: labels)
    }
}
