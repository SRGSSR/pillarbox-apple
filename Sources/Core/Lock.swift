//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Acquires a lock when executing some code.
///
/// - Parameters:
///   - lock: The lock to acquire during execution.
///   - execute: The code to execute.
/// - Returns: The result returned by the executed code.
@discardableResult
public func withLock<T>(_ lock: NSLocking, execute: () -> T) -> T {
    lock.lock()
    let result = execute()
    lock.unlock()
    return result
}
