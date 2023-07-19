//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A Commanders Act event.
public struct CommandersActEvent {
    let name: String
    let customLabels: [String: String]

    /// Creates a Commanders Act event.
    ///
    /// Custom labels which might accidentally override official labels will be ignored.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - customLabels: Additional custom information associated with the event.
    public init(
        name: String,
        customLabels: [String: String] = [:]
    ) {
        assert(!name.isBlank, "A name is required")
        self.name = name
        self.customLabels = customLabels
    }
}
