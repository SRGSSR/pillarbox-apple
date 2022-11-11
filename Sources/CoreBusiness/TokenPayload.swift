//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct Token: Decodable {
    private let authparams: String

    func queryItems() -> [URLQueryItem]? {
        var components = URLComponents()
        components.query = authparams
        return components.queryItems
    }
}

struct TokenPayload: Decodable {
    let token: Token
}
