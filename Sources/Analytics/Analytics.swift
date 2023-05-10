//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import UIKit

/// Gathers analytics according to SRG SSR standards. The associated singleton instance must be started with `start(with:)`
/// before use.
public class Analytics {
    /// Analytics configuration.
    public struct Configuration {
        let vendor: Vendor
        let sourceKey: String
        let site: String

        /// Configure analytics. `sourceKey` and `site` must be obtained from the SRG SSR Digital Analytics team (ADI).
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

    /// Application states.
    public enum ApplicationState {
        /// Foreground and background.
        case foregroundAndBackground
        /// Foreground only.
        case foreground
    }

    /// The singleton instance.
    public static var shared = Analytics()

    private var configuration: Configuration?

    private let comScoreService = ComScoreService()
    private let commandersActService = CommandersActService()

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

        UIViewController.setupViewControllerTracking()
        UITabBarController.setupTabBarControllerTracking()

        comScoreService.start(with: configuration)
        commandersActService.start(with: configuration)
    }

    /// Track a page view.
    /// - Parameters:
    ///   - title: The page title.
    ///   - levels: The page levels.
    ///   - state: The application states for which the page can be tracked. Defaults to `.foreground`. The
    ///     `.foregroundAndBackground` option should only be used in the rare cases where page views must be recorded
    ///     also while the application is in background, e.g. when tracking a CarPlay user interface.
    public func trackPageView(title: String, levels: [String] = [], in state: ApplicationState = .foreground) {
        assert(!title.isBlank, "A title is required")
        guard state == .foregroundAndBackground || UIApplication.shared.applicationState != .background else { return }
        comScoreService.trackPageView(title: title, levels: levels)
        commandersActService.trackPageView(title: title, levels: levels)
    }

    /// Send an event.
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
