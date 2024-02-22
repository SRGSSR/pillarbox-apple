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
    private static func errorCodePublisher(for player: Player) -> AnyPublisher<URLError.Code?, Never> {
        player.$error
            .map { error in
                guard let error else { return nil }
                return .init(rawValue: (error as NSError).code)
            }
            .eraseToAnyPublisher()
    }

    func testNoStream() {
        let player = Player()
        expectNothingPublishedNext(from: player.$error, during: .milliseconds(500))
    }

    func testValidStream() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expectNothingPublishedNext(from: player.$error, during: .milliseconds(500))
    }
}
