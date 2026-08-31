//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Foundation

extension PlayerItem {
    private static func mock(
        input: AssetLoaderMock.Input,
        trackerAdapters: [TrackerAdapter<AssetPlayerMetadata>] = []
    ) -> Self {
        self.init(assetLoaderType: AssetLoaderMock.self, input: input, trackerAdapters: trackerAdapters)
    }

    static func playable(
        url: URL,
        metadata: PlayerMetadata = .empty,
        after delay: TimeInterval = 0,
        trackerAdapters: [TrackerAdapter<AssetPlayerMetadata>] = []
    ) -> Self {
        mock(input: .playable(url: url, metadata: metadata, after: delay), trackerAdapters: trackerAdapters)
    }

    static func playable(
        url: URL,
        metadata: PlayerMetadata,
        after delay: TimeInterval = 0,
        updatedWithMetadata updatedMetadata: PlayerMetadata,
        interval: TimeInterval = 0,
        trackerAdapters: [TrackerAdapter<AssetPlayerMetadata>] = []
    ) -> Self {
        mock(
            input: .playable(url: url, metadata: metadata, after: delay, updatedWithMetadata: updatedMetadata, interval: interval),
            trackerAdapters: trackerAdapters
        )
    }

    static func failing(
        with error: Error,
        after delay: TimeInterval = 0,
        trackerAdapters: [TrackerAdapter<AssetPlayerMetadata>] = []
    ) -> Self {
        mock(input: .failing(with: error, after: delay), trackerAdapters: trackerAdapters)
    }

    static func unavailable(
        with error: Error,
        after delay: TimeInterval = 0,
        trackerAdapters: [TrackerAdapter<AssetPlayerMetadata>] = []
    ) -> Self {
        mock(input: .unavailable(with: error, after: delay), trackerAdapters: trackerAdapters)
    }
}
