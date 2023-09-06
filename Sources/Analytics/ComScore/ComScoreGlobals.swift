//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// An enum representing the user consent options for comScore.
public enum ComScoreConsent: String {
    /// The user's consent status is unknown.
    case unknown = ""

    /// The user has accepted comScore analytics.
    case accepted = "1"

    /// The user has declined comScore analytics.
    case declined = "0"
}

/// A struct representing global labels to send to comScore.
public struct ComScoreGlobals {
    let labels: [String: String]

    /// Creates comScore global labels.
    ///
    /// - Parameters:
    ///   - consent: The user's consent status.
    ///   - labels: Additional information associated with the global labels.
    public init(consent: ComScoreConsent, labels: [String: String]) {
        self.labels = labels.merging(["cs_ucfr": consent.rawValue]) { _, new in new }
    }
}
