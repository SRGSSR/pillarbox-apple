//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation

enum MediaMock: String {
    case media1
    case media2
}

enum MockError: Error {
    case mock
}

extension PlayerItem {
    static func mock(
        url: URL,
        loadedAfter delay: TimeInterval,
        trackerAdapters: [TrackerAdapter<Never>] = []
    ) -> Self {
        let publisher = Just(Asset.simple(url: url))
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher, trackerAdapters: trackerAdapters)
    }

    static func mock(
        url: URL,
        loadedAfter delay: TimeInterval,
        withMetadata: AssetMetadataMock,
        trackerAdapters: [TrackerAdapter<AssetMetadataMock>] = []
    ) -> Self {
        let publisher = Just(Asset.simple(url: url, metadata: withMetadata))
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher, trackerAdapters: trackerAdapters)
    }

    static func mock(
        url: URL,
        withMetadataUpdateAfter delay: TimeInterval,
        trackerAdapters: [TrackerAdapter<AssetMetadataMock>] = []
    ) -> Self {
        let publisher = Just(Asset.simple(
            url: url,
            metadata: AssetMetadataMock(
                title: "title1",
                subtitle: "subtitle1",
                description: "description1"
            )
        ))
        .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        .prepend(Asset.simple(
            url: url,
            metadata: AssetMetadataMock(
                title: "title0",
                subtitle: "subtitle0",
                description: "description0"
            )
        ))
        return .init(publisher: publisher, trackerAdapters: trackerAdapters)
    }

    static func webServiceMock(media: MediaMock, trackerAdapters: [TrackerAdapter<AssetMetadataMock>] = []) -> Self {
        let url = URL(string: "http://localhost:8123/json/\(media).json")!
        let publisher = URLSession(configuration: .ephemeral).dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: AssetMetadataMock.self, decoder: JSONDecoder())
            .map { metadata in
                Asset.simple(url: url, metadata: metadata)
            }
        return .init(publisher: publisher, trackerAdapters: trackerAdapters)
    }

    static func failed() -> Self {
        .init(publisher: Just(Asset<Never>.failed(error: MockError.mock)))
    }
}
