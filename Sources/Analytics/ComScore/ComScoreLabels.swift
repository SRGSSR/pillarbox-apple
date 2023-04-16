//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Labels associated with a comScore event.
public struct ComScoreLabels: Decodable {
    var ns_st_ev: String?
    var ns_ap_ev: String?
    var recorder_session_id: String?

    // MARK: Common
    var c2: String?
    var ns_ap_an: String?
    var mp_brand: String?
    var mp_v: String?

    // MARK: Labels related to page views.
    var ns_category: String?

    // MARK: Labels related to streaming.
    var ns_st_mp: String?
    var ns_st_po: Value<Int>?
    var ns_st_ldw: Value<Int>?
}

public extension ComScoreLabels {
    /// A `Value type that conforms to Decodable.
    /// It wraps a `value` of generic type `T` converted from a `String`.
    struct Value<T: Decodable>: Decodable {
        private(set) var value: T?

        /// Creates a new instance by decoding from the given decoder.
        /// - Parameter decoder: the decoder.
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            guard let string = try? container.decode(String.self) else { return }
            let data = Data(string.utf8)
            guard let value = try? JSONDecoder().decode(T.self, from: data) else { return }
            self.value = value
        }
    }
}
