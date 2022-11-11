//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Nimble
import XCTest

final class AkamaiProviderTests: XCTestCase {
    func testTokenizeUrl() {
        expectSuccess(
            from: AkamaiProvider().tokenizeUrl(URL(string: "https://srgssrch.akamaized.net/hls/live/2022017/srgssr-hls-stream13-ch-dvr/master.m3u8")!)
        )
    }
}


