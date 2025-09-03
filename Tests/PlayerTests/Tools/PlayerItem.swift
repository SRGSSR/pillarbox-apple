//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation
import PillarboxStreams

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
        return .init(publisher: publisher, trackerAdapters: trackerAdapters)
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
        return .init(publisher: publisher, trackerAdapters: trackerAdapters)
    }

    static func failing(with error: Error, after delay: TimeInterval) -> Self {
        let publisher = Fail<Asset<Void>, Error>(error: error)
            .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher)
    }

    static func unavailable(with error: Error, after delay: TimeInterval) -> Self {
        let publisher = Just(Asset.unavailable(with: error, metadata: ()))
            .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher)
    }
}
