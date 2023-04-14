//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

// TODO: Possible to have an even simpler implementation using Decodable?
//       See https://forums.swift.org/t/converting-numbers-in-string-to-int/38566/2 for example.

/// Labels associated with a ComScore event.
public struct ComScoreLabels {
    let dictionary: [String: String]

    /// Value of `c2`.
    public var c2: String? {
        extract { $0 }
    }

    /// Value of `ns_ap_an`.
    public var ns_ap_an: String? {
        extract { $0 }
    }

    /// Value of `mp_brand`.
    public var mp_brand: String? {
        extract { $0 }
    }

    /// Value of `mp_v`.
    public var mp_v: String? {
        extract { $0 }
    }

    private func extract<T>(key: String = #function, conversion: (String) -> T?) -> T? {
        guard let value = dictionary[key] else { return nil }
        return conversion(value)
    }
}

/// Labels related to page views.
public extension ComScoreLabels {
    /// Value of `ns_category`.
    var ns_category: String? {
        extract { $0 }
    }
}

/// Labels related to streaming.
public extension ComScoreLabels {
    /// Value of `ns_st_mp`.
    var ns_st_mp: String? {
        extract { $0 }
    }

    /// Value of `ns_st_po`.
    var ns_st_po: Int? {
        extract { Int($0) }
    }

    /// Value of `ns_st_ldw`.
    var ns_st_ldw: Int? {
        extract { Int($0) }
    }
}
