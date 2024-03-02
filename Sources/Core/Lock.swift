//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

func withLock(_ lock: NSLocking, execute: () -> Void) {
    lock.lock()
    execute()
    lock.unlock()
}
