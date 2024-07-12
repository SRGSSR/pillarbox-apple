//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import OrderedCollections

public extension Array where Element: Hashable {
    /// Removes duplicates from the receiver, preserving the initial item order.
    ///
    /// - Returns: The array without duplicate items.
    func removeDuplicates() -> [Element] {
        var itemDictionnary = [Element: Bool]()
        return filter { itemDictionnary.updateValue(true, forKey: $0) == nil }
    }

    /// Subtracts an array from the receiver.
    ///
    /// - Parameter other: The array to subtract.
    /// - Returns: The receiver, from which elements from the provided array are removed.
    func subtracting(_ other: [Element]) -> [Element] {
        Array(OrderedSet(self).subtracting(Set(other)))
    }
}

public extension Array {
    /// Safely returns the item at the specified index.
    /// 
    /// - Parameter index: The index.
    /// - Returns: The item at the specified index or `nil` if the index is not within range.
    subscript(safeIndex index: Int) -> Element? {
        guard (0..<endIndex).contains(index) else { return nil }
        return self[index]
    }
}
