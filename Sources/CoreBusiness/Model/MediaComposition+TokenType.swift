//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension MediaComposition {
    /// A token type.
    enum TokenType: String, Decodable {
        /// No token.
        case none = "NONE"
        
        /// Akamai token.
        case akamai = "AKAMAI"
    }
}
