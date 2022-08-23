//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum TestStreams {
    static let onDemandUrl = URL(string: "http://localhost:8000/on_demand/master.m3u8")!
    static let shortOnDemandUrl = URL(string: "http://localhost:8000/on_demand_short/master.m3u8")!
    static let corruptOnDemandUrl = URL(string: "http://localhost:8000/on_demand_corrupt/master.m3u8")!

    static let liveUrl = URL(string: "http://localhost:8000/live/master.m3u8")!
    static let dvrSlidingUrl = URL(string: "http://localhost:8000/dvr_sliding/master.m3u8")!
    static let dvrGrowingUrl = URL(string: "http://localhost:8000/dvr_sliding/master.m3u8")!

    static let unavailableUrl = URL(string: "http://localhost:8000/unavailable/master.m3u8")!
    static let customUrl = URL(string: "custom://arbitrary.server/some.m3u8")!
}
