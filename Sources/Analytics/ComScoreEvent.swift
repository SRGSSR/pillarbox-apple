//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public struct ComScoreEvent {
    public let name: String
    public let labels: ComScoreLabels

    init?(from dictionary: [String: String]) {
        guard let name = dictionary["ns_st_ev"] else { return nil }
        self.name = name
        self.labels = ComScoreLabels(dictionary: dictionary)
    }
}

extension ComScoreEvent: CustomDebugStringConvertible {
    public var debugDescription: String {
        name
    }
}
