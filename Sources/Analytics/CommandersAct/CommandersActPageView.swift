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

    /// Additional information associated with the page view.
    public let levels: [String]

    /// The page levels.
    public let labels: [String: String]

    /// Creates a Commanders Act page view.
    /// 
    /// - Parameters:
    ///   - name: The page name.
    ///   - type: The page type (e.g., _Article_).
    ///   - labels: Additional information associated with the page view.
    ///   - levels: The page levels.
    ///
    /// Custom labels which might accidentally override official labels will be ignored.
    public init(name: String, type: String, levels: [String] = [], labels: [String: String] = [:]) {
        assert(!name.isBlank, "A name is required")
        assert(!type.isBlank, "A type is required")
        self.name = name
        self.type = type
        self.levels = levels
        self.labels = labels
    }

    func merging(globals: CommandersActGlobals?) -> Self {
        guard let globals else { return self }
        let labels = labels.merging(globals.labels) { _, new in new }
        return .init(name: name, type: type, levels: levels, labels: labels)
    }
}
