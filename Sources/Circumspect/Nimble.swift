//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Use before tests using Nimble `throwAssertion()` which lead to crashes on tvOS if a debugger is attached, but
/// also to tests never finishing in general.
public func nimbleThrowAssertionsEnabled() -> Bool {
#if os(tvOS)
    if ProcessInfo.processInfo.environment["tvOSNimbleThrowAssertionsEnabled"] == "true" {
        print("[INFO] This test contains Nimble throwing assertions and has been disabled.")
        return true
    }
    else {
        return false
    }
#else
    return true
#endif
}
