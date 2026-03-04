//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A struct describing the section associated with the source of a Commanders Act event.
public struct CommandersActSection {
    let labels: [String: String]

    /// Creates Commanders Act section information.
    ///
    /// - Parameters:
    ///   - identifier: The section identifier
    ///   - version: The section version (e.g. for A/B testing).
    ///   - position: The position within the section.
    public init(identifier: String, version: String? = nil, position: Int? = nil) {
        self.labels = [:]
    }
}
