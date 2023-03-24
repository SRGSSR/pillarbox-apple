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
    let title: String?
    let subtitle: String?
    let description: String?

    init(title: String? = nil, subtitle: String? = nil, description: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
    }
}

extension PlayerItem {
    static func simple(url: URL, delay: TimeInterval) -> Self {
        let publisher = Just(Asset.simple(url: url))
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher)
    }

    static func simple(url: URL, metadata: LocalMetadata, delay: TimeInterval) -> Self {
        let publisher = Just(Asset.simple(url: url, metadata: metadata))
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher)
    }

    static func metadataUpdate(delay: TimeInterval, trackerAdapters: [TrackerAdapter<LocalMetadata>] = []) -> Self {
        let publisher = Just(Asset.simple(
            url: Stream.onDemand.url,
            metadata: LocalMetadata(
                title: "title1",
                subtitle: "subtitle1",
                description: "description1"
            )
        ))
        .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        .prepend(Asset.simple(
            url: Stream.onDemand.url,
            metadata: LocalMetadata(
                title: "title0",
                subtitle: "subtitle0",
                description: "description0"
            )
        ))
        return .init(publisher: publisher, trackerAdapters: trackerAdapters)
    }

    static func networkLoaded(media: LocalMedia) -> Self {
        let url = URL(string: "http://localhost:8123/\(media).json")!
        let publisher = URLSession(configuration: .ephemeral).dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: LocalMetadata.self, decoder: JSONDecoder())
            .map { metadata in
                Asset.simple(
                    url: Stream.onDemand.url,
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
