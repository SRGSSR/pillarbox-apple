//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxCoreBusiness
import SRGDataProvider

@objc
enum ServerSetting: Int, CaseIterable {
    case ilProduction
    case ilStage
    case ilTest

    case ilProductionCH
    case ilStageCH
    case ilTestCH

    case productionWW
    case stageWW
    case testWW

    case samProduction
    case samStage
    case samTest

    case mmf

    var title: String {
        switch self {
        case .ilProduction:
            return "IL Production"
        case .ilStage:
            return "IL Stage"
        case .ilTest:
            return "IL Test"
        case .ilProductionCH:
            return "IL Production - CH"
        case .ilStageCH:
            return "IL Stage - CH"
        case .ilTestCH:
            return "IL Test - CH"
        case .productionWW:
            return "IL Production - WW"
        case .stageWW:
            return "IL Stage - WW"
        case .testWW:
            return "IL Test - WW"
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
        case .ilProduction, .ilProductionCH, .productionWW:
            return SRGIntegrationLayerProductionServiceURL()
        case .ilStage, .ilStageCH, .stageWW:
            return SRGIntegrationLayerStagingServiceURL()
        case .ilTest, .ilTestCH, .testWW:
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
        case .ilProductionCH, .ilStageCH, .ilTestCH:
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
