//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import UIKit

/// Represents an action that can be displayed in an info view of a tvOS player.
public enum InfoViewAction {
    /// Uses the default system-provided action.
    case system

    /// Displays no action in the info view.
    case none

    /// Displays a custom action in the info view.
    ///
    /// - Parameters:
    ///   - title: The title of the action button.
    ///   - image: An optional image displayed next to the title.
    ///   - handler: The closure executed when the user selects the action.
    case custom(title: String, image: UIImage? = nil, handler: () -> Void)
}

extension InfoViewAction {
    func toUIAction(dismissing playerViewController: AVPlayerViewController?, defaultAction: UIAction?) -> UIAction? {
        switch self {
        case .system:
            return defaultAction
        case .none:
            return nil
        case let .custom(title, image, handler):
            return UIAction(title: title, image: image) { _ in
                playerViewController?.dismiss(animated: true)
                handler()
            }
        }
    }
}
