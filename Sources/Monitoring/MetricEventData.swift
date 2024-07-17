//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MetricEventData: Encodable {
    let url: String?
    let bitrate: UInt?
    let bandwidth: UInt?
    let bufferDuration: UInt?
    let stallCount: UInt
    let stallDuration: UInt
    let playbackDuration: UInt
    let playerPosition: UInt
}
