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

    private func mediaCompositionPublisher(forUrn urn: String, httpHeaders: [String: String]) -> AnyPublisher<MediaCompositionResponse, Error> {
        session.dataTaskPublisher(for: server.mediaCompositionRequest(forUrn: urn, httpHeaders: httpHeaders))
            .mapHttpErrors()
            .removeDuplicates { $0.data != $1.data }
            .tryMap { data, response in
                MediaCompositionResponse(
                    mediaComposition: try Self.decoder().decode(MediaComposition.self, from: data),
                    response: response
                )
            }
            .eraseToAnyPublisher()
    }

    func polledMediaCompositionIfNeededPublisher(forUrn urn: String, httpHeaders: [String: String]) -> AnyPublisher<MediaCompositionResponse, Error> {
        mediaCompositionPublisher(forUrn: urn, httpHeaders: httpHeaders)
            .flatMap { [weak self] response in // swiftlint:disable:this unused_closure_parameter
                // TODO: Check if polling is needed
                Timer.publish(every: 3, on: .main, in: .common)
                    .autoconnect()
                    .compactMap { _ -> AnyPublisher<MediaCompositionResponse, Error>? in
                        self?.mediaCompositionPublisher(forUrn: urn, httpHeaders: httpHeaders).eraseToAnyPublisher()
                    }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func resizedImageUrl(_ url: URL, width: ImageWidth) -> URL {
        server.resizedImageUrl(url, width: width)
    }

    func tokenizeUrl(_ url: URL) async -> URL {
        await Akamai.tokenizeUrl(url, using: session)
    }
}
