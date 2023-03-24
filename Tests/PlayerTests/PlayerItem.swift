//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import Foundation

enum LocalMedia: String {
    case media1
}

struct LocalMetadata: Decodable {
    let title: String
    let subtitle: String?
    let description: String?

    init(title: String, subtitle: String? = nil, description: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
    }
}

extension PlayerItem {
    static func asynchronous(url: URL, after delay: TimeInterval) -> Self {
        let publisher = Just(Asset.simple(url: url))
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher)
    }

    static func asynchronous(url: URL, metadata: LocalMetadata, after delay: TimeInterval) -> Self {
        let publisher = Just(Asset.simple(url: url, metadata: metadata))
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher)
    }

    static func updated(url: URL, after delay: TimeInterval, trackerAdapters: [TrackerAdapter<LocalMetadata>] = []) -> Self {
        let publisher = Just(Asset.simple(
            url: url,
            metadata: LocalMetadata(
                title: "title1",
                subtitle: "subtitle1",
                description: "description1"
            )
        ))
        .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        .prepend(Asset.simple(
            url: url,
            metadata: LocalMetadata(
                title: "title0",
                subtitle: "subtitle0",
                description: "description0"
            )
        ))
        return .init(publisher: publisher, trackerAdapters: trackerAdapters)
    }

    static func networkLoaded(url: URL, media: LocalMedia) -> Self {
        let url = URL(string: "http://localhost:8123/\(media).json")!
        let publisher = URLSession(configuration: .ephemeral).dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: LocalMetadata.self, decoder: JSONDecoder())
            .map { metadata in
                Asset.simple(
                    url: url,
                    metadata: metadata
                )
            }
        return .init(publisher: publisher)
    }
}

extension LocalMetadata: AssetMetadata {
    func nowPlayingMetadata() -> NowPlayingMetadata {
        .init(title: title, subtitle: subtitle, description: description)
    }
}
