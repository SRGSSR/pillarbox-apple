//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

public typealias AssetPlayerMetadata = AssetMetadata<EmptyCustomData>

extension AssetPlayerMetadata {
    init(playerMetadata: PlayerMetadata) {
        self.playerMetadata = playerMetadata
        self.customData = .init()
    }
}

// swiftlint:enable missing_docs
