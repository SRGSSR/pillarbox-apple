//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProvider

enum ServiceUrl: String, CaseIterable {
    case production
    case staging
    case test

    var title: String {
        self.rawValue.capitalized
    }

    var url: URL {
        switch self {
        case .production:
            return SRGIntegrationLayerProductionServiceURL()
        case .staging:
            return SRGIntegrationLayerStagingServiceURL()
        case .test:
            return SRGIntegrationLayerTestServiceURL()
        }
    }
}
