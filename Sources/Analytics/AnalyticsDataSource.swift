//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public protocol AnalyticsDataSource: AnyObject {
    var comScoreGlobals: ComScoreGlobals { get }
    var commandersActGlobals: CommandersActGlobals { get }
}
