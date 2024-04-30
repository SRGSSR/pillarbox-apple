//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct Seek: Equatable {
    let position: Position
    let isSmooth: Bool
    let completionHandler: (Bool) -> Void

    private let id = UUID()

    init(_ position: Position, isSmooth: Bool, completionHandler: @escaping (Bool) -> Void) {
        self.position = position
        self.isSmooth = isSmooth
        self.completionHandler = completionHandler
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
