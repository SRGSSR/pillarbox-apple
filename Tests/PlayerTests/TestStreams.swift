//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum TestStreams {
    static let validStreamUrl = URL(string: "http://localhost:8000/on_demand/master.m3u8")!
    static let shortStreamUrl = URL(string: "http://localhost:8000/on_demand_short/master.m3u8")!
    static let corruptStreamUrl = URL(string: "http://localhost:8000/on_demand_corrupt/master.m3u8")!
    static let unavailableStreamUrl = URL(string: "http://localhost:8000/unavailable/master.m3u8")!
    static let customStreamUrl = URL(string: "custom://arbitrary.server/some.m3u8")!
}
