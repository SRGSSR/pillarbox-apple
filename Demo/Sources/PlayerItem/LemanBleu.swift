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

extension PlayerItem {
    static func lemanBleu(for url: URL) -> Self {
        self.init(publisher: asset(for: url))
    }
}

extension PlayerItem {
    private static func asset(for url: URL) -> AnyPublisher<Asset<Never>, any Error> {
        mediaUrlPublisher(for: url)
            .tryMap { Asset.simple(url: $0) }
            .eraseToAnyPublisher()
    }

    private static func mediaUrlPublisher(for url: URL) -> AnyPublisher<URL, LemanBleuError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .map { String(data: $0, encoding: .utf8) }
            .tryMap { html in
                if let mediaURL = try #/data-video-url=".*,(?<url>.*\.mp4)/#.firstMatch(in: html!)?.url {
                    URL(string: "https://www.lemanbleu.ch\(mediaURL)")!
                }
                else {
                    throw LemanBleuError.mediaUrlNotFound
                }
            }
            .mapError { _ in .mediaUrlNotFound }
            .eraseToAnyPublisher()
    }
}
