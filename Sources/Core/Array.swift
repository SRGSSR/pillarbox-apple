//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public extension Array where Element: Hashable {
    /// Remove duplicates from the array.
    /// - Returns: The array without duplicate items. Order is preserved.
    func removeDuplicates() -> [Element] {
        var itemDictionnary = [Element: Bool]()
        return filter { itemDictionnary.updateValue(true, forKey: $0) == nil }
    }
}
