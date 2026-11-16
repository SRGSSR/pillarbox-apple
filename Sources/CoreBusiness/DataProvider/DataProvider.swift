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

    private func mediaCompositionPublisher(forUrn urn: String, httpHeaders: [String: String]) -> AnyPublisher<MediaCompositionResponse, Error> {
        session.dataTaskPublisher(for: server.mediaCompositionRequest(forUrn: urn, httpHeaders: httpHeaders))
            .mapHttpErrors()
            .tryMap { data, response in
                try MediaCompositionResponse(data: data, response: response)
            }
            .eraseToAnyPublisher()
    }

    func polledMediaCompositionIfNeededPublisher(forUrn urn: String, httpHeaders: [String: String]) -> AnyPublisher<MediaCompositionResponse, Error> {
        mediaCompositionPublisher(forUrn: urn, httpHeaders: httpHeaders)
            .map { [weak self] response -> AnyPublisher<MediaCompositionResponse, Error> in
                guard let self, response.isScheduledLivestream else {
                    return Just(response)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return Timer.publish(every: 5, on: .main, in: .common) // TODO: Should this value be hardcoded/configured?
                // Or should we check the cache max-age to extract the value?
                    .autoconnect()
                    .map { [weak self] _ -> AnyPublisher<MediaCompositionResponse, Error> in
                        guard let self else { return Empty().eraseToAnyPublisher() }
                        return mediaCompositionPublisher(forUrn: urn, httpHeaders: httpHeaders)
                    }
                    .switchToLatest()
                    .prepend(response)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func resizedImageUrl(_ url: URL, width: ImageWidth) -> URL {
        server.resizedImageUrl(url, width: width)
    }

    func tokenizeUrl(_ url: URL) async -> URL {
        await Akamai.tokenizeUrl(url, using: session)
    }
}
