//
//  Copyright (c) SRG SSR. All rights reserved.
//x tow
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
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            summary: description,
            imageData: nil /* FIXME */,
            viewport: viewport,
            episodeInformation: episodeInformation,
            chapters: chapters,
            timeRanges: timeRanges,
            analyticsData: customData.analyticsData,
            analyticsMetadata: customData.analyticsMetadata
        )
    }
}

// swiftlint:enable missing_docs
