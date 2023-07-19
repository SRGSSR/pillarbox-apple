//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A Commanders Act event.
public struct CommandersActEvent {
    let name: String
    let type: String
    let value: String
    let source: String
    let extra1: String
    let extra2: String
    let extra3: String
    let extra4: String
    let extra5: String
    let customLabels: [String: String]

    /// Creates a Commanders Act event.
    ///
    /// Custom labels which might accidentally override official labels will be ignored.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - type: The event type.
    ///   - value: The event value.
    ///   - source: The event source.
    ///   - extra1: Extra information associated with the event.
    ///   - extra2: Extra information associated with the event.
    ///   - extra3: Extra information associated with the event.
    ///   - extra4: Extra information associated with the event.
    ///   - extra5: Extra information associated with the event.
    ///   - customLabels: Additional custom information associated with the event.
    public init(
        name: String,
        type: String = "",
        value: String = "",
        source: String = "",
        extra1: String = "",
        extra2: String = "",
        extra3: String = "",
        extra4: String = "",
        extra5: String = "",
        customLabels: [String: String] = [:]
    ) {
        assert(!name.isBlank, "A name is required")
        self.name = name
        self.type = type
        self.value = value
        self.source = source
        self.extra1 = extra1
        self.extra2 = extra2
        self.extra3 = extra3
        self.extra4 = extra4
        self.extra5 = extra5
        self.customLabels = customLabels
    }
}
