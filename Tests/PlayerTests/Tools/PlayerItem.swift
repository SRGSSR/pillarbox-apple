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

extension PlayerItem {
    static func mock(
        url: URL,
        loadedAfter delay: TimeInterval,
        trackerAdapters: [TrackerAdapter<Void>] = []
    ) -> Self {
        let publisher = Just(Asset.simple(url: url))
            .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher, trackerAdapters: trackerAdapters)
    }

    static func mock(
        url: URL,
        loadedAfter delay: TimeInterval,
        withMetadata: AssetMetadataMock,
        trackerAdapters: [TrackerAdapter<AssetMetadataMock>] = []
    ) -> Self {
        let publisher = Just(Asset.simple(url: url, metadata: withMetadata))
            .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(
            publisher: publisher,
            trackerAdapters: trackerAdapters
        )
    }

    static func mock(
        url: URL,
        withMetadataUpdateAfter delay: TimeInterval,
        trackerAdapters: [TrackerAdapter<AssetMetadataMock>] = []
    ) -> Self {
        let publisher = Just(Asset.simple(
            url: url,
            metadata: AssetMetadataMock(title: "title1", subtitle: "subtitle1")
        ))
        .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
        .prepend(Asset.simple(
            url: url,
            metadata: AssetMetadataMock(title: "title0", subtitle: "subtitle0")
        ))
        return .init(
            publisher: publisher,
            trackerAdapters: trackerAdapters
        )
    }

    static func webServiceMock(media: MediaMock, trackerAdapters: [TrackerAdapter<AssetMetadataMock>] = []) -> Self {
        let url = URL(string: "http://localhost:8123/json/\(media).json")!
        let publisher = URLSession(configuration: .default).dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: AssetMetadataMock.self, decoder: JSONDecoder())
            .map { metadata in
                Asset.simple(url: url, metadata: metadata)
            }
        return .init(
            publisher: publisher,
            trackerAdapters: trackerAdapters
        )
    }
}
