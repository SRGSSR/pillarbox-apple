//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A Commanders Act event.
public struct CommandersActEvent {
    /// Event names.
    public enum Name: String {
        case play
        case pause
        case seek
        case stop
        case eof
        case page_view
        case hidden_event
    }

    /// The event name.
    public let name: Name

    /// Labels associated with the event.
    public let labels: CommandersActLabels

    init?(from labels: CommandersActLabels) {
        guard let name = Name(rawValue: labels.event_name ?? "") else { return nil }
        self.name = name
        self.labels = labels
    }
}

extension CommandersActEvent: CustomDebugStringConvertible {
    public var debugDescription: String {
        name.rawValue
    }
}
