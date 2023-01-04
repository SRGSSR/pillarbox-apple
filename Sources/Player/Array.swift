//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension Array where Self.Element : Equatable {
    func elements(of source: Self, from pivot: Self.Element?) -> Self {
        guard let pivot else { return self }
        
        if let pivotIndex = firstIndex(of: pivot) {
            return Self(suffix(from: pivotIndex))
        } else if let otherPivotIndex = source.firstIndex(of: pivot) {
            let elements = source.suffix(from: otherPivotIndex).dropFirst()
            guard let commonItem = elements.first(where: { contains($0) }),
                  let commonItemIndex = firstIndex(of: commonItem) else { return self }
            return Self(suffix(from: commonItemIndex))
        } else { return self }
    }
}
