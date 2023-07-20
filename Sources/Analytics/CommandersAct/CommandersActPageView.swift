//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A Commanders Act page view.
public struct CommandersActPageView {
    let name: String
    let type: String
    let levels: [String]
    let labels: [String: String]

    /// Creates a Commanders Act page view.
    /// 
    /// Custom labels which might accidentally override official labels will be ignored.
    /// 
    /// - Parameters:
    ///   - name: The page name.
    ///   - type: The page type (e.g. Article).
    ///   - labels: Additional information associated with the page view.
    ///   - levels: The page levels.
    public init(name: String, type: String, levels: [String] = [], labels: [String: String] = [:]) {
        assert(!name.isBlank, "A name is required")
        assert(!type.isBlank, "A type is required")
        self.name = name
        self.type = type
        self.levels = levels
        self.labels = labels
    }
}
