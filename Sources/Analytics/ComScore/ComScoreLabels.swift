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
        extract { $0 }
    }

    var ns_ap_ev: String? {
        extract { $0 }
    }

    var listener_session_id: String? {
        extract { $0 }
    }

    private func extract<T>(key: String = #function, conversion: (String) -> T?) -> T? {
        guard let value = dictionary[key] else { return nil }
        return conversion(value)
    }
}

/// Common labels.
public extension ComScoreLabels {
    /// Value of `c2`.
    var c2: String? {
        extract { $0 }
    }

    /// Value of `ns_ap_an`.
    var ns_ap_an: String? {
        extract { $0 }
    }

    /// Value of `mp_brand`.
    var mp_brand: String? {
        extract { $0 }
    }

    /// Value of `mp_v`.
    var mp_v: String? {
        extract { $0 }
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
