//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A hit sent by the comScore SDK.
public struct ComScoreHit {
    /// A name describing a comScore hit.
    public enum Name: String {
        case play
        case pause
        case end
        case view
    }

    /// The hit name.
    public let name: Name

    /// The labels associated with the hit.
    public let labels: ComScoreLabels

    init?(from labels: ComScoreLabels) {
        guard let name = Name(rawValue: labels.ns_st_ev ?? labels.ns_ap_ev ?? "") else { return nil }
        self.name = name
        self.labels = labels
    }
}

extension ComScoreHit: CustomDebugStringConvertible {
    public var debugDescription: String {
        name.rawValue
    }
}
