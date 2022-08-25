//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

@MainActor
final class StreamTypeTests: XCTestCase {
    func testNoItem() throws {
        expect(StreamType.streamType(for: nil)).to(equal(.unknown))
    }

    func testNonReadyOnDemandStream() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        expect(item.status).to(equal(.unknown))
        expect(StreamType.streamType(for: nil)).to(equal(.unknown))
    }

    func testReadyOnDemandStream() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let _ = AVPlayer(playerItem: item)
        expect(item.status).toEventually(equal(.readyToPlay))
        expect(StreamType.streamType(for: item)).to(equal(.onDemand))
    }
}
