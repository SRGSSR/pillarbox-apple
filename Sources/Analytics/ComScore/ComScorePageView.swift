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
    /// - Parameters:
    ///   - name: The page name.
    ///   - labels: Additional information associated with the page view.
    ///
    /// Custom labels which might accidentally override official labels will be ignored.
    public init(name: String, labels: [String: String] = [:]) {
        assert(!name.isBlank, "A name is required")
        self.name = name
        self.labels = labels
    }

    func merging(globals: ComScoreGlobals?) -> Self {
        guard let globals else { return self }
        let labels = labels.merging(globals.labels) { _, new in new }
        return .init(name: name, labels: labels)
    }
}
