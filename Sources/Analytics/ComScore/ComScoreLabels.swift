//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Labels associated with a comScore event.
public struct ComScoreLabels {
    let dictionary: [String: String]

    var ns_st_ev: String? {
        extract()
    }

    var ns_ap_ev: String? {
        extract()
    }

    var listener_session_id: String? {
        extract()
    }

    private func extract<T: LosslessStringConvertible>(_ key: String = #function) -> T? {
        guard let value = dictionary[key] else { return nil }
        return .init(value)
    }

    subscript<T: LosslessStringConvertible>(index: String) -> T? {
        extract(index)
    }
}

/// Common labels.
public extension ComScoreLabels {
    /// Value of `c2`.
    var c2: String? {
        extract()
    }

    /// Value of `ns_ap_an`.
    var ns_ap_an: String? {
        extract()
    }

    /// Value of `mp_brand`.
    var mp_brand: String? {
        extract()
    }

    /// Value of `mp_v`.
    var mp_v: String? {
        extract()
    }
}

/// Labels related to page views.
public extension ComScoreLabels {
    /// Value of `ns_category`.
    var ns_category: String? {
        extract()
    }
}

/// Labels related to streaming.
public extension ComScoreLabels {
    /// Value of `ns_st_mp`.
    var ns_st_mp: String? {
        extract()
    }

    /// Value of `ns_st_po`.
    var ns_st_po: Double? {
        guard let value: Double = extract() else { return nil }
        return value / 1000
    }

    /// Value of `ns_st_ldw`.
    var ns_st_ldw: Double? {
        guard let value: Double = extract() else { return nil }
        return value / 1000
    }

    /// Value of `ns_st_ldo`.
    var ns_st_ldo: Double? {
        guard let value: Double = extract() else { return nil }
        return value / 1000
    }
}
