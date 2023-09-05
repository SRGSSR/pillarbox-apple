//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A struct representing the global labels to send to Commanders Act.
public struct CommandersActGlobals {
    let consentServices: [String]
    let labels: [String: String]

    /// Creates a Commanders Act global labels.
    /// - Parameters:
    ///   - consentServices: The list of service allowed.
    ///   - labels: Additional information associated with the global labels.
    public init(consentServices: [String], labels: [String: String]) {
        self.consentServices = consentServices
        self.labels = labels
    }
}
