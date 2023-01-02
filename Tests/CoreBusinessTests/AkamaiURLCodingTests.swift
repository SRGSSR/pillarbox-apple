//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Nimble
import XCTest

final class AkamaiURLCodingTests: XCTestCase {
    private static let uuid = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"

    func testEncoding() {
        expect(AkamaiURLCoding.encodeUrl(
            URL(string: "http://www.server.com/playlist.m3u8?param1=value1&param2=value2")!,
            id: UUID(uuidString: Self.uuid)!
        ))
        .to(equal(URL(string: "akamai+E621E1F8-C36C-495A-93FC-0C247A3E6E5F+http://www.server.com/playlist.m3u8?param1=value1&param2=value2")))

        expect(AkamaiURLCoding.encodeUrl(
            URL(string: "https://www.server.com/playlist.m3u8?param1=value1&param2=value2")!,
            id: UUID(uuidString: Self.uuid)!
        ))
        .to(equal(URL(string: "akamai+E621E1F8-C36C-495A-93FC-0C247A3E6E5F+https://www.server.com/playlist.m3u8?param1=value1&param2=value2")))
    }

    func testFailedEncoding() {
        expect(AkamaiURLCoding.encodeUrl(
            URL(string: "//www.server.com/playlist.m3u8?param1=value1&param2=value2")!,
            id: UUID(uuidString: Self.uuid)!
        ))
        .to(equal(URL(string: "//www.server.com/playlist.m3u8?param1=value1&param2=value2")))
    }

    func testDecoding() {
        expect(AkamaiURLCoding.decodeUrl(
            URL(string: "akamai+E621E1F8-C36C-495A-93FC-0C247A3E6E5F+http://www.server.com/playlist.m3u8?param1=value1&param2=value2")!,
            id: UUID(uuidString: Self.uuid)!
        ))
        .to(equal(URL(string: "http://www.server.com/playlist.m3u8?param1=value1&param2=value2")))

        expect(AkamaiURLCoding.decodeUrl(
            URL(string: "akamai+E621E1F8-C36C-495A-93FC-0C247A3E6E5F+https://www.server.com/playlist.m3u8?param1=value1&param2=value2")!,
            id: UUID(uuidString: Self.uuid)!
        ))
        .to(equal(URL(string: "https://www.server.com/playlist.m3u8?param1=value1&param2=value2")))
    }

    func testFailedDecoding() {
        expect(AkamaiURLCoding.decodeUrl(
            URL(string: "http://www.server.com/playlist.m3u8?param1=value1&param2=value2")!,
            id: UUID(uuidString: Self.uuid)!
        ))
        .to(beNil())

        expect(AkamaiURLCoding.decodeUrl(
            URL(string: "https://www.server.com/playlist.m3u8?param1=value1&param2=value2")!,
            id: UUID(uuidString: Self.uuid)!
        ))
        .to(beNil())

        expect(AkamaiURLCoding.decodeUrl(
            URL(string: "custom://www.server.com/playlist.m3u8?param1=value1&param2=value2")!,
            id: UUID(uuidString: Self.uuid)!
        ))
        .to(beNil())

        expect(AkamaiURLCoding.decodeUrl(
            URL(string: "//www.server.com/playlist.m3u8?param1=value1&param2=value2")!,
            id: UUID(uuidString: Self.uuid)!
        ))
        .to(beNil())

        expect(AkamaiURLCoding.decodeUrl(
            URL(string: "akamai+1111111-1111-1111-1111-111111111111+https://www.server.com/playlist.m3u8?param1=value1&param2=value2")!,
            id: UUID(uuidString: Self.uuid)!
        ))
        .to(beNil())
    }
}
