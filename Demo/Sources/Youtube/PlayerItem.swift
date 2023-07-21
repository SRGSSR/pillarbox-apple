//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import Player
import YouTubeKit

enum YoutubeError: Error {
    case url
    case error(Error)
}

extension PlayerItem {
    static func youtube(videoId: String) -> Self {
        let publisher = Future<Asset<Never>, YoutubeError> { promise in
            Task {
                do {
                    let stream = try await YouTube(videoID: videoId)
                        .streams
                        .filter { $0.subtype == "mp4" }
                        .highestAudioBitrateStream()
                    guard let url = stream?.url else {
                        return promise(.failure(.url))
                    }
                    return promise(.success(.simple(url: url)))
                }
                catch {
                    return promise(.failure(.error(error)))
                }
            }
        }
        .eraseToAnyPublisher()

        return self.init(publisher: publisher)
    }
}
