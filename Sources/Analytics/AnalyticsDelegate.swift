//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A delegate for analytics events.
public protocol AnalyticsDelegate: AnyObject {
    func didTrackPageView(commandersAct commandersActPageView: CommandersActPageView)
    func didSendEvent(commandersAct commandersActEvent: CommandersActEvent)
}
