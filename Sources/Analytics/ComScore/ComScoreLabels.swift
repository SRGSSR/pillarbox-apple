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

    subscript<T: LosslessStringConvertible>(key: String) -> T? {
        extract(key)
    }
}

/// Common labels.
public extension ComScoreLabels {
    /// Value of `c2` (comScore account).
    var c2: String? {
        extract()
    }

    /// Value of `ns_ap_an` (application name).
    var ns_ap_an: String? {
        extract()
    }
}

/// Mediapulse labels.
public extension ComScoreLabels {
    /// Value of `mp_brand` (vendor).
    var mp_brand: String? {
        extract()
    }

    /// Value of `mp_v` (application version).
    var mp_v: String? {
        extract()
    }
}

/// Labels related to page views.
public extension ComScoreLabels {
    /// Value of `ns_category` (name of the section).
    var ns_category: String? {
        extract()
    }
}

/// Labels related to streaming.
public extension ComScoreLabels {
    /// Value of `ns_st_mp` (media player name).
    var ns_st_mp: String? {
        extract()
    }

    /// Value of `ns_st_mv` (media player version).
    var ns_st_mv: String? {
        extract()
    }

    /// Value of `ns_st_po` (playback position).
    var ns_st_po: Double? {
        guard let value: Double = extract() else { return nil }
        return value / 1000
    }

    /// Value of `ns_st_ldw` (DVR window length).
    var ns_st_ldw: Double? {
        guard let value: Double = extract() else { return nil }
        return value / 1000
    }

    /// Value of `ns_st_ldo` (DVR live edge offset).
    var ns_st_ldo: Double? {
        guard let value: Double = extract() else { return nil }
        return value / 1000
    }
}
