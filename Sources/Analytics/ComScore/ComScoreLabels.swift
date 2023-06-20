//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// The labels associated with a comScore event.
public struct ComScoreLabels {
    let dictionary: [String: String]

    var listener_session_id: String? {
        extract()
    }

    // MARK: Common labels

    /// The value of `ns_ap_ev` (application event).
    public var ns_ap_ev: String? {
        extract()
    }

    /// The value of `c2` (comScore account).
    public var c2: String? {
        extract()
    }

    /// The value of `ns_ap_an` (application name).
    public var ns_ap_an: String? {
        extract()
    }

    // MARK: Mediapulse labels

    /// The value of `mp_brand` (vendor).
    public var mp_brand: String? {
        extract()
    }

    /// The value of `mp_v` (application version).
    public var mp_v: String? {
        extract()
    }

    // MARK: Page view labels

    /// The value of `c8` (name of the section).
    public var c8: String? {
        extract()
    }

    // MARK: Streaming labels

    /// The value of `ns_st_ev` (streaming event).
    public var ns_st_ev: String? {
        extract()
    }

    /// The value of `ns_st_mp` (media player name).
    public var ns_st_mp: String? {
        extract()
    }

    /// The value of `ns_st_mv` (media player version).
    public var ns_st_mv: String? {
        extract()
    }

    /// The value of `ns_st_po` (playback position).
    public var ns_st_po: Double? {
        guard let value: Double = extract() else { return nil }
        return value / 1000
    }

    /// The value of `ns_st_ldw` (DVR window length).
    public var ns_st_ldw: Double? {
        guard let value: Double = extract() else { return nil }
        return value / 1000
    }

    /// The value of `ns_st_ldo` (DVR live edge offset).
    public var ns_st_ldo: Double? {
        guard let value: Double = extract() else { return nil }
        return value / 1000
    }

    /// The value of `ns_st_rt` (playback rate).
    public var ns_st_rt: Int? {
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
