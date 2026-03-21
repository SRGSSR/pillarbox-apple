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
        withMetadata metadata: PlayerMetadata = .empty,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = []
    ) -> Self {
        self.init(
            assetLoader: AssetLoaderMock.self,
            input: .init(asset: .simple(url: url, metadata: metadata), delay: delay),
            trackerAdapters: trackerAdapters
        )
    }

    static func mock(
        url: URL,
        withMetadataUpdateAfter delay: TimeInterval,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = []
    ) -> Self {
        self.init(
            assetLoader: UpdatingAssetLoaderMock.self,
            input: .init(url: url, delay: delay),
            trackerAdapters: trackerAdapters
        )
    }

    static func failing(with error: Error, after delay: TimeInterval) -> Self {
        self.init(
            assetLoader: FailingAssetLoaderMock.self,
            input: .init(error: error, delay: delay)
        )
    }

    static func unavailable(
        with error: Error,
        metadata: PlayerMetadata = .empty,
        after delay: TimeInterval
    ) -> Self {
        self.init(
            assetLoader: AssetLoaderMock.self,
            input: .init(asset: .unavailable(with: error, metadata: metadata), delay: delay)
        )
    }
}
