//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// The user labels associated with a Commanders Act hit.
///
/// Mainly used for development-oriented purposes (e.g. unit testing).
public struct CommandersActUser: Decodable {
    /// The consistent anonymous id.
    public let consistent_anonymous_id: String
}

extension CommandersActUser {
    enum CodingKeys: String, CodingKey {
        case consistent_anonymous_id
    }
}
