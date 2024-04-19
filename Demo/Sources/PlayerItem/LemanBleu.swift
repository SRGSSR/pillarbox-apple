//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

enum LemanBleuError: Error {
    case mediaUrlNotFound
}

private struct LemanBleu {
    private static let baseUrl = "https://www.lemanbleu.ch"
    let imageURL: URL
    let mediaURL: URL

    init(imagePath: String, mediaPath: String) {
        self.imageURL = URL(string: Self.baseUrl + imagePath)!
        self.mediaURL = URL(string: Self.baseUrl + mediaPath)!
    }
}

extension PlayerItem {
    static func lemanBleu(for url: URL) -> Self {
        self.init(publisher: asset(for: url))
    }
}

extension PlayerItem {
    private static func asset(for url: URL) -> AnyPublisher<Asset<Void>, any Error> {
        mediaUrlPublisher(for: url)
            .tryMap { Asset.simple(url: $0.mediaURL) }
            .eraseToAnyPublisher()
    }

    private static func mediaUrlPublisher(for url: URL) -> AnyPublisher<LemanBleu, LemanBleuError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .map { String(data: $0, encoding: .utf8)! }
            .tryMap { html in
                if let data = try #/data-video-url="(?<imagePath>.*),(?<mediaPath>.*)\|/#.firstMatch(in: html) {
                    LemanBleu(imagePath: String(data.imagePath), mediaPath: String(data.mediaPath))
                }
                else {
                    throw LemanBleuError.mediaUrlNotFound
                }
            }
            .mapError { _ in .mediaUrlNotFound }
            .eraseToAnyPublisher()
    }
}
