//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension RangeReplaceableCollection {
    /// Moves an item from a given index to another one in the receiver.
    /// 
    /// - Parameters:
    ///   - fromIndex: The index of the item to move.
    ///   - index: The index of the item before which the item must be inserted. Use `endIndex` to move an item to
    ///     the back of the receiver.
    mutating func move(from fromIndex: Index, to index: Index) {
        guard fromIndex != index else { return }
        if fromIndex > index {
            let item = remove(at: fromIndex)
            insert(item, at: index)
        }
        else {
            let item = self[fromIndex]
            insert(item, at: index)
            remove(at: fromIndex)
        }
    }
}
