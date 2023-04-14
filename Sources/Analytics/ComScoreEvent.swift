//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public struct ComScoreEvent {
    public enum Name: String {
        case play
        case pause
        case end
    }

    public let name: Name
    public let labels: ComScoreLabels

    init?(from dictionary: [String: String]) {
        guard let name = Name(rawValue: dictionary["ns_st_ev"] ?? "") else { return nil }
        self.name = name
        self.labels = ComScoreLabels(dictionary: dictionary)
    }
}

extension ComScoreEvent: CustomDebugStringConvertible {
    public var debugDescription: String {
        name.rawValue
    }
}
