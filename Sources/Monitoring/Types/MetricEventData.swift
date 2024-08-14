//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MetricEventData: Encodable {
    let url: String?
    let streamType: String?
    let bitrate: Double?
    let bandwidth: Double?
    let bufferedDuration: Int?
    let airplay: Bool
    let stall: Stall
    let playbackDuration: Int?
    let playerPosition: Int?
}

extension MetricEventData {
    struct Stall: Encodable {
        let count: Int
        let duration: Int
    }
}
