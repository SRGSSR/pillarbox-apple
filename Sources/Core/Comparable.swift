//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension Comparable {
    /// Clamps a comparable value to a given range.
    /// 
    /// - Parameter range: The range.
    /// - Returns: The value clamped to the specified range.
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
