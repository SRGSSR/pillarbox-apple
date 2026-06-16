//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import Foundation
import PillarboxPlayer

public struct URNCustomData {
    let blockingReason: BlockingReason?
    let resource: MediaComposition.Resource?
    let mediaCompositionUrl: URL?
    let analyticsData: [String: String]
    let analyticsMetadata: [String: String]
}

public typealias URNMetadata = AssetMetadata<URNCustomData>

@available(iOS 17.0, *)
extension URNMetadata {
    var entryMetadata: URNAssetDownloadStore.EntryMetadata {
        .init(
            identifier: playerMetadata.identifier,
            title: playerMetadata.title,
            subtitle: playerMetadata.subtitle,
            summary: playerMetadata.description,
            imageData: nil /* FIXME */,
            viewport: playerMetadata.viewport,
            episodeInformation: playerMetadata.episodeInformation,
            chapters: playerMetadata.chapters,
            timeRanges: playerMetadata.timeRanges,
            analyticsData: customData.analyticsData,
            analyticsMetadata: customData.analyticsMetadata
        )
    }
}

// swiftlint:enable missing_docs
