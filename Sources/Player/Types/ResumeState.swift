//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class ResumeState {
    var position: Position?
    let id: UUID

    var isEmpty: Bool {
        position == nil
    }

    init(position: Position, id: UUID) {
        self.position = position
        self.id = id
    }

    func position(for id: UUID) -> Position? {
        guard self.id == id else { return nil }
        defer {
            position = nil
        }
        return position
    }
}
