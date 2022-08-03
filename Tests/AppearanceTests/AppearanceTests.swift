@testable import Appearance
import XCTest

final class AppearanceTests: XCTestCase {
    func testDummy() {
        XCTAssertTrue(true)
    }
    
    func testPlatformSpecific() {
#if os(iOS)
        XCTFail("Fails on iOS")
#endif
    }
}
