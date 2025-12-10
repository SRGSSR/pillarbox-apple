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

    @MainActor
    func testReset() async {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        await expect(player.error).toEventuallyNot(beNil())
        player.removeAllItems()
        await expect(player.error).toEventually(beNil())
    }

    @MainActor
    func testNotBusyWhenError() async {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        await expect(player.error).toEventuallyNot(beNil())
        expect(player.properties.isBusy).to(beFalse())
    }

    @MainActor
    func testErrorType() async {
        let player = Player(item: .failing(with: MockError(), after: 0.1))
        await expect(player.error is MockError).toEventually(beTrue())
    }

    @MainActor
    func testUnavailableErrorType() async {
        let player = Player(item: .unavailable(with: MockError(), after: 0.1))
        await expect(player.error is MockError).toEventually(beTrue())
    }
}
