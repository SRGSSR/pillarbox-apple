//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Nimble
import XCTest

final class AkamaiURLCodingTests: XCTestCase {
    func testEncoding() {
        expect(AkamaiURLCoding.encodeUrl(URL(string: "http://www.server.com/playlist.m3u8?param1=value1&param2=value2")!))
            .to(equal(URL(string: "akamai+http://www.server.com/playlist.m3u8?param1=value1&param2=value2")))
        expect(AkamaiURLCoding.encodeUrl(URL(string: "https://www.server.com/playlist.m3u8?param1=value1&param2=value2")!))
            .to(equal(URL(string: "akamai+https://www.server.com/playlist.m3u8?param1=value1&param2=value2")))
    }

    func testFailedEncoding() {
        expect(AkamaiURLCoding.encodeUrl(URL(string: "//www.server.com/playlist.m3u8?param1=value1&param2=value2")!))
            .to(equal(URL(string: "//www.server.com/playlist.m3u8?param1=value1&param2=value2")))
    }

    func testDecoding() {
        expect(AkamaiURLCoding.decodeUrl(URL(string: "akamai+http://www.server.com/playlist.m3u8?param1=value1&param2=value2")!))
            .to(equal(URL(string: "http://www.server.com/playlist.m3u8?param1=value1&param2=value2")))
        expect(AkamaiURLCoding.decodeUrl(URL(string: "akamai+https://www.server.com/playlist.m3u8?param1=value1&param2=value2")!))
            .to(equal(URL(string: "https://www.server.com/playlist.m3u8?param1=value1&param2=value2")))
    }

    func testFailedDecoding() {
        expect(AkamaiURLCoding.decodeUrl(URL(string: "http://www.server.com/playlist.m3u8?param1=value1&param2=value2")!))
            .to(beNil())
        expect(AkamaiURLCoding.decodeUrl(URL(string: "https://www.server.com/playlist.m3u8?param1=value1&param2=value2")!))
            .to(beNil())
        expect(AkamaiURLCoding.decodeUrl(URL(string: "custom://www.server.com/playlist.m3u8?param1=value1&param2=value2")!))
            .to(beNil())
        expect(AkamaiURLCoding.decodeUrl(URL(string: "//www.server.com/playlist.m3u8?param1=value1&param2=value2")!))
            .to(beNil())
    }
}
