//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Information sent with analytics events.
struct Labels {
    /// comScore-specific information.
    let comScore: [String: String]

    /// Commanders Act-specific information.
    let commandersAct: [String: String]

    /// Merge labels together.
    /// - Parameter other: The other labels which must be merged into the receiver.
    /// - Returns: The merged labels.
    func merging(_ other: Self) -> Self {
        .init(
            comScore: comScore.merging(other.comScore) { _, new in new },
            commandersAct: commandersAct.merging(other.commandersAct) { _, new in new }
        )
    }
}
