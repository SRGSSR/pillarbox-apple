//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import XCTest

final class VersionTests: XCTestCase {
    func testGitTag() {
        expect(Version.gitTag).toNot(beEmpty())
    }
}
