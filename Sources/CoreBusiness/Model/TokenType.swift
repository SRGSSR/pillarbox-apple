//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A token type.
public enum TokenType: String, Decodable {
    /// No token.
    case none = "NONE"

    /// Akamai token.
    case akamai = "AKAMAI"
}
