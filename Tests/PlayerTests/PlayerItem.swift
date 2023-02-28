//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import Foundation

enum Metadata: String {
    case media1
}

private struct AssetMetadata: Decodable {
    let title: String
    let subtitle: String
    let description: String
}

extension PlayerItem {
    static func simple(url: URL, metadata: Asset.Metadata? = nil, delay: TimeInterval) -> Self {
        let publisher = Just(Asset.simple(url: url, metadata: metadata))
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher)
    }

    static func metadataUpdate(delay: TimeInterval) -> Self {
        let publisher = Just(Asset.simple(
            url: Stream.onDemand.url,
            metadata: .init(
                title: "title1",
                subtitle: "subtitle1",
                description: "description1"
            )
        ))
        .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        .prepend(Asset.simple(
            url: Stream.onDemand.url,
            metadata: .init(
                title: "title0",
                subtitle: "subtitle0",
                description: "description0"
            )
        ))
        return .init(publisher: publisher)
    }

    static func networkLoaded(metadata: Metadata) -> Self {
        let url = URL(string: "http://localhost:8123/\(metadata).json")!
        let publisher = URLSession(configuration: .ephemeral).dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: AssetMetadata.self, decoder: JSONDecoder())
            .map { metadata in
                Asset.simple(
                    url: Stream.onDemand.url,
                    metadata: .init(
                        title: metadata.title,
                        subtitle: metadata.subtitle,
                        description: metadata.description
                    )
                )
            }
        return .init(publisher: publisher)
    }
}
