//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Player
import UIKit
import YouTubeKit

extension PlayerItem {
    static func youTube(videoId: String) -> Self {
        self.init(
            publisher: Publishers.CombineLatest(
                urlPublisher(videoId: videoId),
                imagePublisher(videoId: videoId)
                    .prepend(UIImage())
                    .setFailureType(to: YouTubeError.self)
            )
            .map { url, image in
                Asset.simple(url: url, metadata: YouTubeMetadata(videoId: videoId, url: url, image: image))
            }
        )
    }

    private static func urlPublisher(videoId: String) -> AnyPublisher<URL, YouTubeError> {
        Future<URL, YouTubeError> { promise in
            Task {
                do {
                    let liveStream = try await YouTube(videoID: videoId).livestreams.first
                    let stream = try await YouTube(videoID: videoId).streams
                        .filter { $0.subtype == "mp4" && $0.includesVideoTrack }
                        .highestAudioBitrateStream()

                    guard let url = liveStream?.url ?? stream?.url else { return promise(.failure(.url)) }
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
