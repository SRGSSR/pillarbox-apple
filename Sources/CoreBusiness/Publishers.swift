//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

extension Publisher {
    func mapHttpErrors() -> Publishers.TryMap<Self, Output> where Output == URLSession.DataTaskPublisher.Output {
        return tryMap { result in
            if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
                throw NetworkError.http(statusCode: httpResponse.statusCode)
            }
            return result
        }
    }
}
