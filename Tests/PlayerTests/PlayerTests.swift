@testable import Player
import Nimble
import XCTest

final class PlayerTests: XCTestCase {
    func testInitialState() {
        let player = Player()
        expect(player.state).to(equal(.idle))
    }
}
