//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxMonitoring

extension MetricsTracker.Configuration {
    static let test = MetricsTracker.Configuration(
        identifier: "identifier",
        serviceUrl: URL(string: "https://localhost/ingest")!
    )

    static let heartbeatTest = MetricsTracker.Configuration(
        identifier: "identifier",
        serviceUrl: URL(string: "https://localhost/ingest")!,
        heartbeatInterval: 1
    )
}

extension MetricsTracker.Metadata {
    static let test = MetricsTracker.Metadata(
        metadataUrl: URL(string: "https://localhost/metadata.json"),
        assetUrl: URL(string: "https://localhost/asset.m3u8")
    )
}
