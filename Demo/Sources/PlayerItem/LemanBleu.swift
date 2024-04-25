//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer
import UIKit

enum LemanBleuError: Error {
    case mediaUrlNotFound
}

private struct LemanBleuMetadata: AssetMetadata {
    let title: String
    let image: UIImage

    var playerMetadata: PlayerMetadata {
        .init(title: title, image: image)
    }
}

private struct LemanBleu {
    private static let baseUrl = "https://www.lemanbleu.ch"
    let imageURL: URL
    let mediaURL: URL
    let title: String

    init(title: String, imagePath: String, mediaPath: String) {
        self.title = title
        if mediaPath.hasPrefix("https://") {
            self.mediaURL = URL(string: mediaPath)!
        }
        else {
            self.mediaURL = URL(string: Self.baseUrl + mediaPath)!
        }
        self.imageURL = URL(string: Self.baseUrl + imagePath)!
    }
}

extension PlayerItem {
    static func lemanBleu(for url: URL) -> Self {
        self.init(publisher: asset(for: url))
    }
}

extension PlayerItem {
    private static func asset(for url: URL) -> AnyPublisher<Asset<LemanBleuMetadata>, any Error> {
        mediaUrlPublisher(for: url)
            .tryMap { lemanBleu in
                imagePublisher(for: lemanBleu.imageURL)
                    .map { image in
                        Asset.simple(url: lemanBleu.mediaURL, metadata: .init(title: lemanBleu.title, image: image))
                    }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    private static func mediaUrlPublisher(for url: URL) -> AnyPublisher<LemanBleu, LemanBleuError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .map { String(data: $0, encoding: .utf8)! }
            .tryMap { html in
                if
                    let data = try #/data-video-url="(?<imagePath>.*),(?<mediaPath>.*)\|/#.firstMatch(in: html),
                    let metadata = try #/class="pageTitle">(?<title>.*)</#.firstMatch(in: html) {
                    LemanBleu(title: String(metadata.title), imagePath: String(data.imagePath), mediaPath: String(data.mediaPath))
                }
                else {
                    throw LemanBleuError.mediaUrlNotFound
                }
            }
            .mapError { _ in .mediaUrlNotFound }
            .eraseToAnyPublisher()
    }

    private static func imagePublisher(for url: URL) -> AnyPublisher<UIImage, Never> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .replaceError(with: Data())
            .compactMap { UIImage(data: $0) }
            .eraseToAnyPublisher()
    }
}
