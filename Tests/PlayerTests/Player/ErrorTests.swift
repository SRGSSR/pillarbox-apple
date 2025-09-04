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

private struct MockError: Error {}

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
        expectAtLeastEqualPublishedNext(
            values: [.init(rawValue: NSURLErrorFileDoesNotExist)],
            from: Self.errorCodePublisher(for: player)
        )
    }

    func testReset() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.error).toEventuallyNot(beNil())
        player.removeAllItems()
        expect(player.error).toEventually(beNil())
    }

    func testNotBusyWhenError() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.error).toEventuallyNot(beNil())
        expect(player.properties.isBusy).to(beFalse())
    }

    func testErrorType() {
        let player = Player(item: .failing(with: MockError(), after: 0.1))
        expect(player.error is MockError).toEventually(beTrue())
    }

    func testUnavailableErrorType() {
        let player = Player(item: .unavailable(with: MockError(), after: 0.1))
        expect(player.error is MockError).toEventually(beTrue())
    }
}
