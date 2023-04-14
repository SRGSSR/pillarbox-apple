//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public struct CommandersActEvent {
    public enum Name: String {
        case play
        case pause
        case eof
        case page_view
        case hidden_event
    }

    public let name: Name
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
