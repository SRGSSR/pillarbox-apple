//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Labels associated with a ComScore event.
public struct ComScoreLabels {
    let dictionary: [String: String]

    /// Value of `ns_st_po`.
    public var ns_st_po: Int? {
        extract(key: "ns_st_po") { Int($0) }
    }

    /// Value of `ns_st_ldw`.
    public var ns_st_ldw: Int? {
        extract(key: "ns_st_ldw") { Int($0) }
    }

    private func extract<T>(key: String, conversion: (String) -> T?) -> T? {
        guard let value = dictionary[key] else { return nil }
        return conversion(value)
    }
}


