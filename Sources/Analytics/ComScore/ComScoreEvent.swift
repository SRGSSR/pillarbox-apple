//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// An event sent by the comScore SDK.
public struct ComScoreEvent {
    /// A name describing a comScore event.
    public enum Name: String {
        case play
        case pause
        case end
        case view
    }

    /// The event name.
    public let name: Name

    /// The labels associated with the event.
    public let labels: ComScoreLabels

    init?(from labels: ComScoreLabels) {
        guard let name = Name(rawValue: labels.ns_st_ev ?? labels.ns_ap_ev ?? "") else { return nil }
        self.name = name
        self.labels = labels
    }
}

extension ComScoreEvent: CustomDebugStringConvertible {
    public var debugDescription: String {
        name.rawValue
    }
}
