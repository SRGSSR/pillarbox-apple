//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import UIKit

/// Content associated with ``SystemVideoView`` actions.
public struct SystemVideoViewActionsContent {
    static let empty = Self(actions: [])

    let actions: [SystemVideoViewAction]

    func contextualActions() -> [UIAction] {
        actions.map { $0.toContextualAction() }
    }

    func infoViewActions(dismissing playerViewController: AVPlayerViewController) -> [UIAction] {
        actions.map { $0.toInfoViewAction(dismissing: playerViewController) }
    }
}
