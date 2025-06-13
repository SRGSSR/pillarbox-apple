//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A delegate for analytics events.
public protocol AnalyticsDelegate: AnyObject {
    /// Called when a page view has been tracked.
    ///
    /// - Parameter commandersActPageView: The Commanders Act page view.
    func didTrackPageView(commandersAct commandersActPageView: CommandersActPageView)

    /// Called when an event has been sent.
    ///
    /// - Parameter commandersActEvent: The Commanders Act event.
    func didSendEvent(commandersAct commandersActEvent: CommandersActEvent)
}
