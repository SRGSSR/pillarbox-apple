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
    case mmf

    var title: String {
        switch self {
        case .production:
            return "Production"
        case .stage:
            return "Stage"
        case .test:
            return "Test"
        case .mmf:
            return "MMF"
        }
    }

    var url: URL {
        switch self {
        case .production:
            return SRGIntegrationLayerProductionServiceURL()
        case .stage:
            return SRGIntegrationLayerStagingServiceURL()
        case .test:
            return SRGIntegrationLayerTestServiceURL()
        case .mmf:
            return URL(string: Bundle.main.infoDictionary?["MMFServiceURL"] as! String)!
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
        case .mmf:
            return .custom(baseUrl: url)
        }
    }
}
