//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Foundation
import Nimble
import PillarboxCircumspect

final class MoviePackageTests: TestCase {
    func testExtractKeyUrlsFromEmptyPlaylist() {
        expect(MoviePackage.extractKeyUrls(from: "")).to(beEmpty())
    }

    // swiftlint:disable:next inclusive_language
    func testExtractKeyUrlsFromMasterPlaylist() {
        expect(MoviePackage.extractKeyUrls(
            from: """
                #EXTM3U
                #EXT-X-SESSION-KEY:METHOD=AES-128,URI="http://localhost/serve.key"
                """
        )).to(equalDiff([
            URL(string: "http://localhost/serve.key")!
        ]))
    }

    func testExtractKeyUrlsFromMediaPlaylist() {
        expect(MoviePackage.extractKeyUrls(
            from: """
                #EXTM3U
                #EXT-X-TARGETDURATION:2
                #EXT-X-KEY:METHOD=AES-128,URI="http://localhost/serve.key?session=1",IV=0x00000000000000000000000000000001
                #EXTINF:2.000,
                seg-1.ts
                #EXT-X-KEY:METHOD=SAMPLE-AES,URI="skd://key",KEYFORMAT="com.apple.streamingkeydelivery"
                #EXTINF:2.000,
                seg-2.ts
                #EXT-X-KEY:METHOD=AES-128,URI="data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAA=="
                #EXTINF:2.000,
                seg-3.ts
                #EXT-X-KEY:METHOD=AES-128,IV=0x00000000000000000000000000000001,URI="https://localhost/serve.key?session=2"
                #EXTINF:2.000,
                seg-4.ts
                #EXT-X-KEY:URI="https://localhost/serve.key?session=3",METHOD=SAMPLE-AES
                #EXTINF:2.000,
                seg-5.ts
                #EXT-X-KEY:METHOD=NONE
                #EXTINF:2.000,
                seg-6.ts
                """
        )).to(equalDiff([
            URL(string: "http://localhost/serve.key?session=1")!,
            URL(string: "https://localhost/serve.key?session=2")!
        ]))
    }

    func testReplaceUrlWithData() {
        expect(MoviePackage.replaceUrl(
            URL(string: "http://localhost/serve.key")!,
            with: Data(repeating: 1, count: 16),
            in: """
                #EXTM3U
                #EXT-X-SESSION-KEY:METHOD=AES-128,URI="http://localhost/serve.key"
                """
        )).to(equal(
            """
            #EXTM3U
            #EXT-X-SESSION-KEY:METHOD=AES-128,URI="data:application/octet-stream;base64,AQEBAQEBAQEBAQEBAQEBAQ=="
            """
        ))
    }

    func testInlineAES128Keys() async {
        await expect {
            await MoviePackage.inlineAES128Keys(
                in: """
                    #EXTM3U
                    #EXT-X-SESSION-KEY:METHOD=AES-128,URI="http://localhost:8123/aes128/test.key"
                    """
            )
        }.to(equal(
            """
            #EXTM3U
            #EXT-X-SESSION-KEY:METHOD=AES-128,URI="data:application/octet-stream;base64,AQEBAQEBAQEBAQEBAQEBAQ=="
            """
        ))
    }
}
