//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A struct describing a location associated with the source of a Commanders Act event.
public struct CommandersActLocation {
    let identifier: String
    let version: String?
    let position: String?

    /// Creates Commanders Act location information.
    ///
    /// - Parameters:
    ///   - identifier: The location identifier
    ///   - version: The location version (e.g. for A/B testing).
    ///   - position: The position within the location.
    public init(identifier: String, version: String? = nil, position: Int? = nil) {
        self.identifier = identifier
        self.version = version
        self.position = Self.string(from: position)
    }

    static func string(from integer: Int?) -> String? {
        guard let integer else { return nil }
        return String(integer)
    }
}
