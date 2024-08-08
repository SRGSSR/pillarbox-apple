//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import DequeModule
import Foundation
import PillarboxCore

final class WorkQueue: @unchecked Sendable {
    typealias WorkItem = () async throws -> Void

    private var items: Deque<WorkItem> = []
    private let lock = NSRecursiveLock()

    var count: Int {
        withLock(lock) {
            items.count
        }
    }

    func add(_ item: @escaping WorkItem) {
        withLock(lock) {
            items.append(item)
        }
    }

    func process() {
        Task {
            for item in items {
                try await item()
                withLock(lock) {
                    items.removeFirst()
                }
            }
        }
    }
}
