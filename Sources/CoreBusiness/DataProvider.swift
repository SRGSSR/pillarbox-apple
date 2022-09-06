//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

final class DataProvider {
    let environment: Environment
    let session: URLSession

    init(environment: Environment = .production) {
        self.environment = environment
        session = URLSession(configuration: .default)
    }

    func mediaComposition(forUrn urn: String) -> AnyPublisher<MediaComposition, Error> {
        let url = environment.url.appending(path: "integrationlayer/2.1/mediaComposition/byUrn/\(urn)")
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MediaComposition.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
