//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A comScore page view.
public struct ComScorePageView {
    let name: String
    let labels: [String: String]

    /// Creates a comScore page view.
    ///
    /// Custom labels which might accidentally override official labels will be ignored.
    ///
    /// - Parameters:
    ///   - name: The page view name.
    ///   - labels: Additional information associated with the page view.
    public init(name: String, labels: [String: String] = [:]) {
        assert(!name.isBlank, "A name is required")
        self.name = name
        self.labels = labels
    }
}
