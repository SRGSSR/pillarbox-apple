//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A protocol for analytics data sources.
public protocol AnalyticsDataSource: AnyObject {
    /// comScore global labels.
    var comScoreGlobals: ComScoreGlobals { get }

    /// Commanders Act global labels.
    var commandersActGlobals: CommandersActGlobals { get }
}
