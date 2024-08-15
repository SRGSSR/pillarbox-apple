//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MetricStatusEventData: Encodable {
    let airplay: Bool
    let bandwidth: Double?
    let bitrate: Double?
    let bufferedDuration: Int?
    let duration: Int?
    let playbackDuration: Int?
    let position: Int?
    let positionTimestamp: Int?
    let stall: Stall
    let streamType: String?
    let url: String?
    let vpn: Bool
}

extension MetricStatusEventData {
    struct Stall: Encodable {
        let count: Int
        let duration: Int
    }
}
