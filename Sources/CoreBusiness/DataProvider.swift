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

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    func mediaComposition(forUrn urn: String) -> AnyPublisher<MediaComposition, Error> {
        let url = environment.url.appending(path: "integrationlayer/2.1/mediaComposition/byUrn/\(urn)")
        return session.dataTaskPublisher(for: url)
            .mapHttpErrors()
            .map(\.data)
            .decode(type: MediaComposition.self, decoder: Self.decoder())
            .eraseToAnyPublisher()
    }

    func recommendedResource(forUrn urn: String) -> AnyPublisher<Resource, Error> {
        mediaComposition(forUrn: urn)
            .map(\.mainChapter.recommendedResource)
            .tryMap { resource in
                guard let resource else {
                    throw DataError.notFound
                }
                return resource
            }
            .eraseToAnyPublisher()
    }
}
