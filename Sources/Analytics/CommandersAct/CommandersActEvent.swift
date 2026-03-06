//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A Commanders Act event.
public struct CommandersActEvent {
    /// The event name.
    public let name: String

    /// The source of the event.
    public let source: CommandersActSource?

    /// Additional information associated with the event.
    public let labels: [String: String]

    /// Creates a Commanders Act event.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - labels: Additional information associated with the event.
    ///
    /// Custom labels which might accidentally override official labels will be ignored.
    public init(name: String, source: CommandersActSource? = nil, labels: [String: String] = [:]) {
        assert(!name.isBlank, "A name is required")
        self.name = name
        self.source = source
        self.labels = labels
    }

    func merging(globals: CommandersActGlobals?) -> Self {
        guard let globals else { return self }
        let labels = labels
            .merging(source?.labels ?? [:]) { _, new in new }
            .merging(globals.labels) { _, new in new }
        return .init(name: name, labels: labels)
    }
}
