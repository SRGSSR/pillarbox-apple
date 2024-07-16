//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MetricStartData: Encodable {
    let deviceId: String
    let deviceModel: String
    let deviceType: String
    let screenWidth: UInt
    let screenHeight: UInt
    let osName: String
    let osVersion: String
    let playerName: String
    let playerPlatform: String
    let playerVersion: String
    let origin: String
    let mediaId: String
    let mediaSource: String
    let timeMetrics: TimeMetrics
}
