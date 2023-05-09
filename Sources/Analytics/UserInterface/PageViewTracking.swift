//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol PageViewTracking {
    var pageTitle: String { get }
    var pageLevels: [String] { get }
    var isTrackedAutomatically: Bool { get }
}

public extension PageViewTracking {
    var pageLevels: [String] {
        []
    }

    var isTrackedAutomatically: Bool {
        true
    }
}
