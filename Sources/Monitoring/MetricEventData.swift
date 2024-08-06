//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MetricEventData: Encodable {
    let url: String?
    let bitrate: Int?
    let bandwidth: Int?
    let bufferDuration: Int?
    let stallCount: Int?
    let stallDuration: Int?
    let playbackDuration: Int?
    let playerPosition: Int?
}
