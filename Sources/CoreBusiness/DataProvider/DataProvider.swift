//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import UIKit

final class DataProvider {
    enum ImageWidth: Int {
        case width240 = 240
        case width320 = 320
        case width480 = 480
        case width960 = 960
        case width1920 = 1920
    }

    let server: Server
    private let session: URLSession

    private var vector: String {
#if os(iOS)
        return "appplay"
#else
        return "tvplay"
#endif
    }

    init(server: Server = .production) {
        self.server = server
        session = URLSession(configuration: .ephemeral)
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
        session.dataTaskPublisher(for: mediaCompositionUrl(for: urn))
            .mapHttpErrors()
            .map(\.data)
            .decode(type: MediaComposition.self, decoder: Self.decoder())
            .eraseToAnyPublisher()
    }

    func mediaCompositionUrl(for urn: String) -> URL {
        let url = server.url.appending(path: "integrationlayer/2.1/mediaComposition/byUrn/\(urn)")
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        components.queryItems = [
            URLQueryItem(name: "onlyChapters", value: "true"),
            URLQueryItem(name: "vector", value: vector)
        ]
        return components.url ?? url
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

    func imagePublisher(for url: URL, width: ImageWidth) -> AnyPublisher<UIImage, Never> {
        session
            .dataTaskPublisher(for: scaledImageUrl(url, width: width))
            .map(\.data)
            .replaceError(with: Data())
            .compactMap { UIImage(data: $0) }
            .eraseToAnyPublisher()
    }

    func imageCatalogPublisher(for mediaComposition: MediaComposition, width: ImageWidth) -> AnyPublisher<ImageCatalog, Never> {
        Publishers.MergeMany(mediaComposition.allChapters.map { chapter in
            imagePublisher(for: chapter.imageUrl, width: width)
                .map { [chapter.urn: $0] }
        })
        .prepend([:])
        .scan([:]) { initial, next in
            initial.merging(next) { _, new in new }
        }
        .map { ImageCatalog(images: $0, width: width) }
        .eraseToAnyPublisher()
    }

    private func scaledImageUrl(_ url: URL, width: ImageWidth) -> URL {
        guard var components = URLComponents(
            url: server.url.appending(path: "images/"),
            resolvingAgainstBaseURL: false
        ) else {
            return url
        }
        components.queryItems = [
            URLQueryItem(name: "imageUrl", value: url.absoluteString),
            URLQueryItem(name: "format", value: "jpg"),
            URLQueryItem(name: "width", value: String(width.rawValue))
        ]
        if let scaledUrl = components.url {
            return scaledUrl
        }
        else {
            return url
        }
    }
}
