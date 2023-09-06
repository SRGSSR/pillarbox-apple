//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// An enum representing the user consent options for ComScore.
public enum ComScoreConsent: String {
    /// The user's consent status is unknown.
    case unknown = ""

    /// The user has accepted ComScore analytics.
    case accepted = "1"

    /// The user has declined ComScore analytics.
    case declined = "0"
}

/// A struct representing the global labels to send to ComScore.
public struct ComScoreGlobals {
    let consent: ComScoreConsent
    let labels: [String: String]

    var allLabels: [String: String] {
        labels.merging(["cs_ucfr": consent.rawValue]) { _, new in new }
    }

    /// Creates a ComScore global labels.
    /// - Parameters:
    ///   - consent: The user's consent status.
    ///   - labels: Additional information associated with the global labels.
    public init(consent: ComScoreConsent, labels: [String: String]) {
        self.consent = consent
        self.labels = labels
    }
}
