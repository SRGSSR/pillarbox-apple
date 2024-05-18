//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import UIKit

final class DataProvider {
    private let server: Server
    private let session: URLSession

    init(server: Server = .production) {
        self.server = server
        session = URLSession(configuration: .default)
    }

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private static func error(from mediaComposition: MediaComposition) -> Error? {
        let mainChapter = mediaComposition.mainChapter
        if let blockingReason = mainChapter.blockingReason {
            return DataError.blocked(withMessage: blockingReason.description)
        }
        else {
            return nil
        }
    }

    func mediaCompositionPublisher(forUrn urn: String) -> AnyPublisher<MediaComposition, Error> {
        session.dataTaskPublisher(for: server.request(for: urn))
            .mapHttpErrors()
            .map(\.data)
            .decode(type: MediaComposition.self, decoder: Self.decoder())
            .eraseToAnyPublisher()
    }

    func playableMediaCompositionPublisher(forUrn urn: String) -> AnyPublisher<MediaComposition, Error> {
        mediaCompositionPublisher(forUrn: urn)
            .tryMap { mediaComposition in
                if let error = Self.error(from: mediaComposition) {
                    throw error
                }
                return mediaComposition
            }
            .eraseToAnyPublisher()
    }

    func resizedImageUrl(_ url: URL, width: ImageWidth) -> URL {
        server.resizedImageUrl(url, width: width)
    }
}
