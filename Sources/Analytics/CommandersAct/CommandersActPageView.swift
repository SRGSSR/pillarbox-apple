//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A Commanders Act page view.
public struct CommandersActPageView {
    let title: String
    let type: String
    let levels: [String]
    let customLabels: [String: String]

    /// Creates a Commanders Act page view.
    /// 
    /// Custom labels which might accidentally override official labels will be ignored.
    /// 
    /// - Parameters:
    ///   - title: The page title.
    ///   - type: The page type (e.g. Article).
    ///   - customLabels: Additional custom information associated with the page view.
    ///   - levels: The page levels.
    public init(title: String, type: String, levels: [String] = [], customLabels: [String: String] = [:]) {
        assert(!title.isBlank, "A title is required")
        assert(!type.isBlank, "A type is required")
        self.title = title
        self.type = type
        self.levels = levels
        self.customLabels = customLabels
    }
}
