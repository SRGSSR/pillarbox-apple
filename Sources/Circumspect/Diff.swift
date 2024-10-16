//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CustomDump

enum AssertDescription {
    static func difference<T, U>(expected: [T], actual: [U]) -> String {
        "Expected: \(expected), actual: \(actual)"
    }

    static func difference<T>(expected: [T], actual: [T]) -> String {
        diff(expected, actual) ?? "-"
    }
}
