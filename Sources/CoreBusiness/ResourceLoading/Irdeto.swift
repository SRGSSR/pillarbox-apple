//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum Irdeto {
    static func contentKeyContextRequest(from identifier: String, httpBody: Data) -> URLRequest? {
        guard var components = URLComponents(string: identifier) else { return nil }
        components.scheme = "https"
        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = httpBody
        return request
    }

    static func contentIdentifier(from identifier: String) -> Data? {
        guard let components = URLComponents(string: identifier),
              let contentIdentifier = components.queryItems?.first(where: { $0.name == "contentId" })?.value else {
            return nil
        }
        return Data(contentIdentifier.utf8)
    }
}
