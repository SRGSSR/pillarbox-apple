//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble

final class StreamTypeTests: TestCase {
    func testAllCases() {
        expect(StreamType(for: .zero, duration: .invalid)).to(equal(.unknown))
        expect(StreamType(for: .zero, duration: .indefinite)).to(equal(.live))
        expect(StreamType(for: .finite, duration: .indefinite)).to(equal(.dvr))
        expect(StreamType(for: .zero, duration: .zero)).to(equal(.onDemand))
    }
}

private extension CMTimeRange {
    static let finite = Self(start: .zero, duration: .init(value: 1, timescale: 1))
}
