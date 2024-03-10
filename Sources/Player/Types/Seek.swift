//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct Seek: Equatable {
    let time: CMTime
    let toleranceBefore: CMTime
    let toleranceAfter: CMTime
    let isSmooth: Bool
    let completionHandler: (Bool) -> Void

    private let id = UUID()

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
