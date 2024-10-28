//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

final class MediaCompositionDataProvider : DataProvider {
    private let session: URLSession

    init() {
        session = URLSession(configuration: .default)
    }

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    func mediaCompositionPublisher(forUrl url: URL) -> AnyPublisher<MediaCompositionResponse, Error> {
        session.dataTaskPublisher(for: URLRequest.init(url: url))
            .mapHttpErrors()
            .tryMap { data, response in
                let a = try MediaCompositionDataProvider.decoder().decode(MediaComposition.self, from: data)
                return MediaCompositionResponse(
                    mediaComposition: try Self.decoder().decode(MediaComposition.self, from: data),
                    response: response
                )
            }
            .eraseToAnyPublisher()
    }

    func resizedImageUrl(_ url: URL, width: ImageWidth) -> URL {
        // Media Compositions don't provide resize capability
        return url
    }
}
