//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A Commanders Act event.
public struct CommandersActEvent {
    /// The event name.
    public let name: String

    /// Additional information associated with the event.
    public let labels: [String: String]

    /// Creates a Commanders Act event.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - labels: Additional information associated with the event.
    ///
    /// Custom labels which might accidentally override official labels will be ignored.
    public init(name: String, labels: [String: String] = [:]) {
        assert(!name.isBlank, "A name is required")
        self.name = name
        self.labels = labels
    }

    func merging(globals: CommandersActGlobals?) -> Self {
        guard let globals else { return self }
        let labels = labels.merging(globals.labels) { _, new in new }
        return .init(name: name, labels: labels)
    }
}
