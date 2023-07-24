//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Nimble
import XCTest
@testable import YouTubeIdentifier

final class YouTubeIdentifierTests: XCTestCase {
    func testPathWatchWithVParam() {
        let url = URL(string: "https://www.youtube.com/watch?v=GYkq9Rgoj8E")!
        expect(YouTubeIdentifier.extract(from: url)).to(equal("GYkq9Rgoj8E"))
    }

    func testPathWatchWithVParamWithOneOtherParam() {
        let url = URL(string: "https://www.youtube.com/watch?v=GYkq9Rgoj8E&feature=youtu.be")!
        expect(YouTubeIdentifier.extract(from: url)).to(equal("GYkq9Rgoj8E"))
    }

    func testPathWatchWithVParamWithManyOtherParams() {
        let url = URL(string: "https://www.youtube.com/watch?v=GYkq9Rgoj8E&list=RDPLZuH2m_-S4&start_radio=1")!
        expect(YouTubeIdentifier.extract(from: url)).to(equal("GYkq9Rgoj8E"))
    }

    func testPath() {
        let url = URL(string: "https://youtu.be/a9ZHIMZUimk")!
        expect(YouTubeIdentifier.extract(from: url)).to(equal("a9ZHIMZUimk"))
    }

    func testPathWithParams() {
        let url = URL(string: "https://youtu.be/rc46cO3spSE?t=42")!
        expect(YouTubeIdentifier.extract(from: url)).to(equal("rc46cO3spSE"))
    }

    func testEmbed() {
        let url = URL(string: "https://www.youtube.com/embed/GYkq9Rgoj8E")!
        expect(YouTubeIdentifier.extract(from: url)).to(equal("GYkq9Rgoj8E"))
    }

    func testShorts() {
        let url = URL(string: "https://www.youtube.com/shorts/GYkq9Rgoj8E")!
        expect(YouTubeIdentifier.extract(from: url)).to(equal("GYkq9Rgoj8E"))
    }

    func testSpecialCharacter() {
        let url = URL(string: "https://youtube.com/shorts/GxFfWr-NvAY")!
        expect(YouTubeIdentifier.extract(from: url)).to(equal("GxFfWr-NvAY"))
    }
}
