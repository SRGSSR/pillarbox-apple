//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A hit sent by the comScore SDK.
///
/// Mainly used for development-oriented purposes (e.g., unit testing).
public struct ComScoreHit {
    /// A name describing a comScore hit.
    public enum Name: String {
        /// Play.
        case play

        /// Rate change.
        case playrt

        /// Pause.
        case pause

        /// End.
        case end

        /// View.
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
    // swiftlint:disable:next missing_docs
    public var debugDescription: String {
        name.rawValue
    }
}
