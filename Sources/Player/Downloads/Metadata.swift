//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

@available(tvOS, unavailable)
public struct DownloadMetadata<CustomData> {
    public let playerMetadata: PlayerMetadata
    public let customData: CustomData

    public init(playerMetadata: PlayerMetadata, customData: CustomData) {
        self.playerMetadata = playerMetadata
        self.customData = customData
    }

    func withoutCustomData() -> DownloadMetadata<Void> {
        .init(playerMetadata: playerMetadata, customData: ())
    }
}

#endif

// swiftlint:enable missing_docs
