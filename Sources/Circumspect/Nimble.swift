//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Returns whether Nimble throw assertions are available or not.
///
/// Call this function at the start of test methods using Nimble `throwAssertion()`. This ensures that:
/// 
/// - No crashes occur on tvOS when a debugger is attached.
/// - Tests never run endlessly.
public func nimbleThrowAssertionsAvailable() -> Bool {
#if os(tvOS)
    if ProcessInfo.processInfo.environment["tvOSnimbleThrowAssertionsAvailable"] == "true" {
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
