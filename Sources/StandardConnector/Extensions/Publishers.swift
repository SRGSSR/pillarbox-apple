//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

public extension Publisher {
    @_spi(StandardConnectorPrivate)
    func mapHttpErrors() -> Publishers.TryMap<Self, Output> where Output == URLSession.DataTaskPublisher.Output {
        // swiftlint:disable:previous missing_docs
        tryMap { result in
            if let httpError = HttpError(response: result.response) {
                throw httpError
            }
            return result
        }
    }
}
