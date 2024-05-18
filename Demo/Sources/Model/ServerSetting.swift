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

    case productionCH
    case stageCH
    case testCH

    case productionWW
    case stageWW
    case testWW

    case samProduction
    case samStage
    case samTest

    case mmf

    var title: String {
        switch self {
        case .production:
            return "Production"
        case .stage:
            return "Stage"
        case .test:
            return "Test"
        case .productionCH:
            return "Production (CH)"
        case .stageCH:
            return "Stage (CH)"
        case .testCH:
            return "Test (CH)"
        case .productionWW:
            return "Production (WW)"
        case .stageWW:
            return "Stage (WW)"
        case .testWW:
            return "Test (WW)"
        case .samProduction:
            return "SAM Production"
        case .samStage:
            return "SAM Stage"
        case .samTest:
            return "SAM Test"
        case .mmf:
            return "MMF"
        }
    }

    var dataProvider: SRGDataProvider {
        let dataProvider = SRGDataProvider(serviceURL: baseUrl)
        dataProvider.globalParameters = globalParameters
        return dataProvider
    }

    private var baseUrl: URL {
        switch self {
        case .production, .productionCH, .productionWW:
            return SRGIntegrationLayerProductionServiceURL()
        case .stage, .stageCH, .stageWW:
            return SRGIntegrationLayerStagingServiceURL()
        case .test, .testCH, .testWW:
            return SRGIntegrationLayerTestServiceURL()
        case .samProduction:
            return SRGIntegrationLayerProductionServiceURL().appending(component: "sam")
        case .samStage:
            return SRGIntegrationLayerStagingServiceURL().appending(component: "sam")
        case .samTest:
            return SRGIntegrationLayerTestServiceURL().appending(component: "sam")
        case .mmf:
            return URL(string: Bundle.main.infoDictionary?["MMFServiceURL"] as! String)!
        }
    }

    private var globalParameters: [String: String] {
        .init(uniqueKeysWithValues: queryItems.compactMap { item in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })
    }

    private var queryItems: [URLQueryItem] {
        switch self {
        case .productionCH, .stageCH, .testCH:
            return [URLQueryItem(name: "forceLocation", value: "CH")]
        case .productionWW, .stageWW, .testWW:
            return [URLQueryItem(name: "forceLocation", value: "WW")]
        case .samProduction, .samStage, .samTest:
            return [URLQueryItem(name: "forceSAM", value: "true")]
        default:
            return []
        }
    }

    var server: Server {
        .custom(baseUrl: baseUrl, queryItems: queryItems)
    }
}
