//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A Commanders Act event.
public struct CommandersActEvent {
    let name: String
    let labels: [String: String]

    /// Creates a Commanders Act event.
    ///
    /// Custom labels which might accidentally override official labels will be ignored.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - labels: Additional information associated with the event.
    public init(
        name: String,
        labels: [String: String] = [:]
    ) {
        assert(!name.isBlank, "A name is required")
        self.name = name
        self.labels = labels
    }
}
