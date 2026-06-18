//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

@available(tvOS, unavailable)
extension AssetMetadata where CustomData == URNMetadata {
    @available(iOS 17.0, *)
    var entryMetadata: URNAssetDownloadStore.EntryMetadata {
        .init(
            identifier: playerMetadata.identifier,
            title: playerMetadata.title,
            subtitle: playerMetadata.subtitle,
            analyticsData: customData.analyticsData,
            analyticsMetadata: customData.analyticsMetadata
        )
    }
}
