//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxCoreBusiness
import SRGDataProvider

@objc
enum ServerSetting: Int, CaseIterable {
    case production
    case stage
    case test

    var title: String {
        switch self {
        case .production:
            return "Production"
        case .stage:
            return "Stage"
        case .test:
            return "Test"
        }
    }

    var dataProvider: SRGDataProvider {
        .init(serviceURL: baseUrl)
    }

    private var baseUrl: URL {
        switch self {
        case .production:
            return SRGIntegrationLayerProductionServiceURL()
        case .stage:
            return SRGIntegrationLayerStagingServiceURL()
        case .test:
            return SRGIntegrationLayerTestServiceURL()
        }
    }

    var server: Server {
        switch self {
        case .production:
            return .production
        case .stage:
            return .stage
        case .test:
            return .test
        }
    }
}
