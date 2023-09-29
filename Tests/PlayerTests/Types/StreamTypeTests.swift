//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble

final class StreamTypeTests: TestCase {
    func testAllCases() {
        expect(StreamType(for: .zero, itemDuration: .invalid)).to(equal(.unknown))
        expect(StreamType(for: .zero, itemDuration: .indefinite)).to(equal(.live))
        expect(StreamType(for: .finite, itemDuration: .indefinite)).to(equal(.dvr))
        expect(StreamType(for: .zero, itemDuration: .zero)).to(equal(.onDemand))
    }
}

private extension CMTimeRange {
    static var finite: Self {
        .init(start: .zero, duration: .init(value: 1, timescale: 1))
    }
}
