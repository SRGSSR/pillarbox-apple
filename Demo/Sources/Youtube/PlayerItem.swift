//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Player
import UIKit
import YouTubeKit

enum YoutubeError: Error {
    case url
    case error(Error)
}

extension PlayerItem {
    static func youtube(videoId: String) -> Self {
        let youtubePublisher = imagePublisher(videoId: videoId)
            .prepend(UIImage())
            .map { image in
                urlPublisher(videoId: videoId)
                    .map { url in
                        Asset.simple(url: url, metadata: YoutubeMetadata(image: image))
                    }
            }
            .switchToLatest()
            .eraseToAnyPublisher()

        return self.init(publisher: youtubePublisher)
    }

    private static func urlPublisher(videoId: String) -> AnyPublisher<URL, YoutubeError> {
        Future<URL, YoutubeError> { promise in
            Task {
                do {
                    let stream = try await YouTube(videoID: videoId)
                        .streams
                        .filter { $0.subtype == "mp4" }
                        .highestAudioBitrateStream()
                    guard let url = stream?.url else { return promise(.failure(.url)) }
                    return promise(.success(url))
                }
                catch {
                    return promise(.failure(.error(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private static func imagePublisher(videoId: String) -> AnyPublisher<UIImage, Never> {
        let url = URL(string: "https://img.youtube.com/vi/\(videoId)/maxresdefault.jpg")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .compactMap { UIImage(data: $0) }
            .replaceError(with: UIImage())
            .eraseToAnyPublisher()
    }
}
