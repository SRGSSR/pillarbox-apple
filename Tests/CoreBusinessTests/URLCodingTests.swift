//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Nimble
import XCTest

final class URLCodingTests: XCTestCase {
    func testEncoding() {
        expect(URLCoding.encodeUrl(fromUrn: "urn:srf:video:6440e95f-71c5-4510-a165-f81e9c0dd391"))
            .to(equal(URL(string: "pillarbox://mediacomposition.m3u8?urn=urn:srf:video:6440e95f-71c5-4510-a165-f81e9c0dd391")))
        expect(URLCoding.encodeUrl(fromUrn: "random-string"))
            .to(equal(URL(string: "pillarbox://mediacomposition.m3u8?urn=random-string")))
    }

    func testDecoding() {
        expect(URLCoding.decodeUrn(from: URL(string: "pillarbox://mediacomposition?urn=urn:srf:video:6440e95f-71c5-4510-a165-f81e9c0dd391")!))
            .to(equal("urn:srf:video:6440e95f-71c5-4510-a165-f81e9c0dd391"))
        expect(URLCoding.decodeUrn(from: URL(string: "pillarbox://mediacomposition?urn=urn%3Asrf%3Avideo%3A6440e95f-71c5-4510-a165-f81e9c0dd391")!))
            .to(equal("urn:srf:video:6440e95f-71c5-4510-a165-f81e9c0dd391"))
        expect(URLCoding.decodeUrn(from: URL(string: "pillarbox://mediacomposition?invalid=urn:srf:video:6440e95f-71c5-4510-a165-f81e9c0dd391")!))
            .to(beNil())
        expect(URLCoding.decodeUrn(from: URL(string: "invalid://mediacomposition?urn=urn:srf:video:6440e95f-71c5-4510-a165-f81e9c0dd391")!))
            .to(beNil())
    }
}
