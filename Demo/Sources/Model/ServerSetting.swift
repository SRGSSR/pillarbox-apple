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

    case ilProductionWW
    case ilStageWW
    case ilTestWW

    case samProduction
    case samStage
    case samTest

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
        case .ilProductionWW:
            return "IL Production - WW"
        case .ilStageWW:
            return "IL Stage - WW"
        case .ilTestWW:
            return "IL Test - WW"
        case .samProduction:
            return "SAM Production"
        case .samStage:
            return "SAM Stage"
        case .samTest:
            return "SAM Test"
        }
    }

    var dataProvider: SRGDataProvider {
        let dataProvider = SRGDataProvider(serviceURL: baseUrl)
        dataProvider.globalParameters = globalParameters
        return dataProvider
    }

    private var baseUrl: URL {
        switch self {
        case .ilProduction, .ilProductionCH, .ilProductionWW:
            return SRGIntegrationLayerProductionServiceURL()
        case .ilStage, .ilStageCH, .ilStageWW:
            return SRGIntegrationLayerStagingServiceURL()
        case .ilTest, .ilTestCH, .ilTestWW:
            return SRGIntegrationLayerTestServiceURL()
        case .samProduction:
            return SRGIntegrationLayerProductionServiceURL().appending(component: "sam")
        case .samStage:
            return SRGIntegrationLayerStagingServiceURL().appending(component: "sam")
        case .samTest:
            return SRGIntegrationLayerTestServiceURL().appending(component: "sam")
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
        case .ilProductionWW, .ilStageWW, .ilTestWW:
            return [URLQueryItem(name: "forceLocation", value: "WW")]
        case .samProduction, .samStage, .samTest:
            return [URLQueryItem(name: "forceSAM", value: "true")]
        default:
            return []
        }
    }

    var server: Server {
        .init(baseUrl: baseUrl, queryItems: queryItems)
    }
}
