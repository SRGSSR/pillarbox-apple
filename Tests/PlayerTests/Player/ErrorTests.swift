//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class ErrorTests: TestCase {
    func testNoStream() {
        let player = Player()
        expectNothingPublishedNext(from: player.$error, during: .milliseconds(500))
    }
}
