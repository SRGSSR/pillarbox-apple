//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A struct describing the page associated with the source of a Commanders Act event.
public struct CommandersActPage {
    let labels: [String: String]

    /// Creates Commanders Act page information.
    ///
    /// - Parameters:
    ///   - identifier: The page identifier
    ///   - version: The page version (e.g. for A/B testing).
    ///   - position: The position within the page.
    public init(identifier: String, version: String? = nil, position: Int? = nil) {
        self.labels = [:]
    }
}
