//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation
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

    func testInvalidStream() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expectEqualPublishedNext(
            values: [.init(rawValue: NSURLErrorFileDoesNotExist)],
            from: Self.errorCodePublisher(for: player),
            during: .seconds(1)
        )
    }

    func testReset() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.error).toEventuallyNot(beNil())
        player.removeAllItems()
        expect(player.error).toEventually(beNil())
    }
}
