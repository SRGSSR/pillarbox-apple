//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension Numeric where Self: Comparable {
    func clamp(min: Self, max: Self) -> Self {
        Swift.max(min, Swift.min(max, self))
    }
}
