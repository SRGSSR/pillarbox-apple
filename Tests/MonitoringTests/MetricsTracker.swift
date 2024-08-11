//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxMonitoring

extension MetricsTracker.Configuration {
    static let test = MetricsTracker.Configuration(serviceUrl: URL(string: "https://localhost/ingest")!)
}

extension MetricsTracker.Metadata {
    static let test = MetricsTracker.Metadata(identifier: "test_id", metadataUrl: nil, assetUrl: nil)
}
