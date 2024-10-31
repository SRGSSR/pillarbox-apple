//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble

final class PlayerLimitsTests: TestCase {
    func testPlayerLimitsDefaultValues() {
        let limits = PlayerLimits()
        expect(limits.preferredPeakBitRate).to(equal(0))
        expect(limits.preferredPeakBitRateForExpensiveNetworks).to(equal(0))
        expect(limits.preferredMaximumResolution).to(equal(.zero))
        expect(limits.preferredMaximumResolutionForExpensiveNetworks).to(equal(.zero))
    }

    func testPlayerLimitsCustomValues() {
        let limits = PlayerLimits(
            preferredPeakBitRate: 100,
            preferredPeakBitRateForExpensiveNetworks: 200,
            preferredMaximumResolution: .init(width: 100, height: 200),
            preferredMaximumResolutionForExpensiveNetworks: .init(width: 300, height: 400)
        )
        expect(limits.preferredPeakBitRate).to(equal(100))
        expect(limits.preferredPeakBitRateForExpensiveNetworks).to(equal(200))
        expect(limits.preferredMaximumResolution).to(equal(.init(width: 100, height: 200)))
        expect(limits.preferredMaximumResolutionForExpensiveNetworks).to(equal(.init(width: 300, height: 400)))
    }
}
