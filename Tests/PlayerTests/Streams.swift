//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum TestStreams {
    static let validStreamUrl = URL(string: "http://localhost:8000/valid_stream/master.m3u8")!
    static let unavailableStreamUrl = URL(string: "http://httpbin.org/status/404")!
    static let corruptStreamUrl = URL(string: "http://localhost:8000/corrupt_stream/master.m3u8")!
    static let customStreamUrl = URL(string: "custom://arbitrary.server/some.m3u8")!
}
