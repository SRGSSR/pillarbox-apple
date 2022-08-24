//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

final class Counter: ObservableObject {
    @Published var count = 0

    init() {
        Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .map { _ in 1 }
            .scan(0) { $0 + $1 }
            .assign(to: &$count)
    }
}
