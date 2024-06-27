//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

/// Matches close signed numeric values up to a given tolerance.
public func beClose<T>(within tolerance: T) -> ((T, T) -> Bool) where T: Comparable & SignedNumeric {
    { lhs, rhs in
        abs(lhs - rhs) <= tolerance
    }
}
