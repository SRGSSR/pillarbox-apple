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

extension URNMetadata {
    @available(iOS 17.0, *)
    var entryMetadata: URNAssetDownloadStore.EntryMetadata {
        .init(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            analyticsData: customData.analyticsData,
            analyticsMetadata: customData.analyticsMetadata
        )
    }
}

// swiftlint:enable missing_docs
