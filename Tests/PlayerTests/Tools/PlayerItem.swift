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
    private static func mock(
        input: AssetLoaderMockInput,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = []
    ) -> Self {
        self.init(assetLoaderType: AssetLoaderMock.self, input: input, trackerAdapters: trackerAdapters)
    }

    static func playable(
        url: URL,
        metadata: PlayerMetadata = .empty,
        after delay: TimeInterval = 0,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = []
    ) -> Self {
        mock(input: .playable(url: url, metadata: metadata, after: delay), trackerAdapters: trackerAdapters)
    }

    static func updatable(
        url: URL,
        metadata: PlayerMetadata,
        to updatedMetadata: PlayerMetadata,
        after interval: TimeInterval = 0,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = []
    ) -> Self {
        mock(input: .updatable(url: url, metadata: metadata, to: updatedMetadata, after: interval), trackerAdapters: trackerAdapters)
    }

    static func failing(
        with error: Error,
        after delay: TimeInterval = 0,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = []
    ) -> Self {
        mock(input: .failing(with: error, after: delay), trackerAdapters: trackerAdapters)
    }

    static func unavailable(
        with error: Error,
        after delay: TimeInterval = 0,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = []
    ) -> Self {
        mock(input: .unavailable(with: error, after: delay), trackerAdapters: trackerAdapters)
    }
}
