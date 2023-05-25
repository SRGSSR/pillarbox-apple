//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProvider

@objc
enum ServerSetting: Int, CaseIterable {
    case production
    case staging
    case test

    var title: String {
        switch self {
        case .production:
            return "Production"
        case .staging:
            return "Staging"
        case .test:
            return "Test"
        }
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
