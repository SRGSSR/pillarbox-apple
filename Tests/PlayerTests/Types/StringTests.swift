//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble

final class StringTests: TestCase {
    func testWithoutQuotes() {
        expect("key=value".unquotedComponents(separatedBy: "=")).to(equal([
            "key", "value"
        ]))
    }

    func testWithQuotes() {
        expect("key=\"value\"".unquotedComponents(separatedBy: "=")).to(equal([
            "key", "value"
        ]))
    }

    func testWithSeparatorNestedInQuotes() {
        expect("key=\"value=\"".unquotedComponents(separatedBy: "=")).to(equal([
            "key", "value="
        ]))
    }
}
