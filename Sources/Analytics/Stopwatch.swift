//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class Stopwatch {
    private var date: Date?
    private var total: TimeInterval = 0

    func start() {
        guard date == nil else { return }
        date = Date()
    }

    func stop() {
        guard let date else { return }
        total += Date().timeIntervalSince(date)
        self.date = nil
    }

    func time() -> TimeInterval {
        if let date {
            return total + Date().timeIntervalSince(date)
        }
        else {
            return total
        }
    }

    func reset() {
        date = nil
        total = 0
    }
}
