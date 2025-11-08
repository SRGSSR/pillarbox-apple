//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import UIKit

/// A container representing the actions displayed at the top and bottom of an info view.
public struct InfoViewActions {
    /// The top action configuration.
    public let top: InfoViewAction

    /// The bottom action configuration.
    public let bottom: InfoViewAction

    /// Creates a set of info view actions.
    ///
    /// - Parameters:
    ///   - top: The top action.
    ///   - bottom: The bottom action.
    public init(top: InfoViewAction, bottom: InfoViewAction) {
        self.top = top
        self.bottom = bottom
    }
}

extension InfoViewActions {
    func toUIActions(dismissing playerViewController: AVPlayerViewController?, defaultActions: [UIAction]) -> [UIAction] {
        [
            top.toUIAction(dismissing: playerViewController, defaultAction: defaultActions.first),
            bottom.toUIAction(dismissing: playerViewController, defaultAction: defaultActions.last)
        ].compactMap(\.self)
    }
}
