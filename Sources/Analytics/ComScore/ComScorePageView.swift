//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A comScore page view.
public struct ComScorePageView {
    let title: String
    let customLabels: [String: String]

    /// Creates a comScore page view.
    ///
    /// Custom labels which might accidentally override official labels will be ignored.
    ///
    /// - Parameters:
    ///   - title: The page view title.
    ///   - customLabels: Additional custom information associated with the page view.
    public init(title: String, customLabels: [String: String] = [:]) {
        assert(!title.isBlank, "A title is required")
        self.title = title
        self.customLabels = customLabels
    }
}
