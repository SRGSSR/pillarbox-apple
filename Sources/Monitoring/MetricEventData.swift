//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MetricEventData: Encodable {
    let url: String?
    let bitrate: Int?
    let bandwidth: Int?
    let bufferedDuration: Int?
    let stall: Stall
    let playbackDuration: Int?
    let playerPosition: Int?
}

extension MetricEventData {
    struct Stall: Encodable {
        let stallCount: Int?
        let stallDuration: Int?
    }
}
