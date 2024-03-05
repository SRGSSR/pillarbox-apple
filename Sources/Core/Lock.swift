//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

func withLock<T>(_ lock: NSLocking, execute: () -> T) -> T {
    lock.lock()
    let result = execute()
    lock.unlock()
    return result
}
