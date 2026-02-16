//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

@_spi(StandardConnectorPrivate)
import PillarboxStandardConnector

final class DataProvider {
    private let server: Server
    private let session = URLSession(configuration: .default)

    init(server: Server = .production) {
        self.server = server
    }

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    func mediaCompositionPublisher(forUrn urn: String) -> AnyPublisher<MediaCompositionResponse, Error> {
        session.dataTaskPublisher(for: server.mediaCompositionRequest(forUrn: urn))
            .mapHttpErrors()
            .tryMap { data, response in
                MediaCompositionResponse(
                    mediaComposition: try Self.decoder().decode(MediaComposition.self, from: data),
                    response: response
                )
            }
            .eraseToAnyPublisher()
    }

    func resizedImageUrl(_ url: URL, width: ImageWidth) -> URL {
        server.resizedImageUrl(url, width: width)
    }
}
