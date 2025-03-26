//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension Collection where Element: Hashable {
    /// Removes duplicates from the receiver, preserving the initial item order.
    ///
    /// - Returns: The array without duplicate items.
    func removeDuplicates() -> [Element] {
        var elements = [Element: Bool]()
        return filter { elements.updateValue(true, forKey: $0) == nil }
    }
}

public extension Collection {
    /// Safely returns the item at the specified index.
    /// 
    /// - Parameter index: The index.
    /// - Returns: The item at the specified index or `nil` if the index is not within range.
    subscript(safeIndex index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
