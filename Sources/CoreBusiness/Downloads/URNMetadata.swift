//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import PillarboxPlayer

public struct URNCustomData: Codable {
    enum CodingKeys: String, CodingKey {
        case analyticsData
        case analyticsMetadata
    }

    let blockingReason: BlockingReason?
    let resource: MediaComposition.Resource?

    // TODO: Probably should name as comScore and commandersAct labels
    public let analyticsData: [String: String]
    public let analyticsMetadata: [String: String]

    init(blockingReason: BlockingReason?, resource: MediaComposition.Resource?, analyticsData: [String : String], analyticsMetadata: [String : String]) {
        self.blockingReason = blockingReason
        self.resource = resource
        self.analyticsData = analyticsData
        self.analyticsMetadata = analyticsMetadata
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        analyticsData = try container.decode([String: String].self, forKey: .analyticsData)
        analyticsMetadata = try container.decode([String: String].self, forKey: .analyticsMetadata)
        blockingReason = nil
        resource = nil
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(analyticsData, forKey: .analyticsData)
        try container.encode(analyticsMetadata, forKey: .analyticsMetadata)
    }
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
