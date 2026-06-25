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
    case playPlusProduction
    case playPlusIntegration
    case playPlusDevelopment

    var title: String {
        switch self {
        case .production:
            return "Production"
        case .stage:
            return "Stage"
        case .test:
            return "Test"
        case .playPlusProduction:
            return "Play+ Production"
        case .playPlusIntegration:
            return "Play+ Integration"
        case .playPlusDevelopment:
            return "Play+ Development"
        }
    }

    var dataProvider: SRGDataProvider {
        .init(serviceURL: baseUrl)
    }

    private var baseUrl: URL {
        switch self {
        case .production, .playPlusProduction:
            return SRGIntegrationLayerProductionServiceURL()
        case .stage, .playPlusIntegration:
            return SRGIntegrationLayerStagingServiceURL()
        case .test, .playPlusDevelopment:
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
        case .playPlusProduction:
            return .playPlusProduction
        case .playPlusIntegration:
            return .playPlusIntegration
        case .playPlusDevelopment:
            return .playPlusDevelopment
        }
    }
}
