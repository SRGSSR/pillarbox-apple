//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A Commanders Act page view.
public struct CommandersActPageView {
    /// The page name.
    public let name: String

    /// The page type (e.g., _Article_).
    public let type: String

    /// The page levels.
    public let levels: [String]

    /// The source of the event.
    public let source: CommandersActSource?

    /// Additional information associated with the page view.
    public let labels: [String: String]

    /// Creates a Commanders Act page view.
    /// 
    /// - Parameters:
    ///   - name: The page name.
    ///   - type: The page type (e.g., _Article_).
    ///   - levels: The page levels.
    ///   - source: The source of the event.
    ///   - labels: Additional information associated with the page view.
    ///
    /// Custom labels which might accidentally override official labels will be ignored.
    public init(name: String, type: String, levels: [String] = [], source: CommandersActSource? = nil, labels: [String: String] = [:]) {
        assert(!name.isBlank, "A name is required")
        assert(!type.isBlank, "A type is required")
        self.name = name
        self.type = type
        self.source = source
        self.levels = levels
        self.labels = labels
    }

    func merging(globals: CommandersActGlobals?) -> Self {
        guard let globals else { return self }
        let labels = labels
            .merging(source?.labels ?? [:]) { _, new in new }
            .merging(globals.labels) { _, new in new }
        return .init(name: name, type: type, levels: levels, source: source, labels: labels)
    }
}
