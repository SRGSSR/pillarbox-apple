//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import UIKit

/// Actions to present contextually during playback.
public struct InfoViewAction {
    /// Short display title.
    public let title: String

    /// Image that can appear next to this action.
    public let image: UIImage?

    /// The handler to invoke.
    public let handler: () -> Void

    /// Creates a new info view action.
    ///
    /// - Parameters:
    ///   - title: Short display title.
    ///   - image: Image that can appear next to this action.
    ///   - handler: The handler to invoke.
    public init(title: String, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.handler = handler
    }

    /// Creates a new info view action.
    ///
    /// - Parameters:
    ///   - title: Short display title.
    ///   - systemImage: System image name that can appear next to this action.
    ///   - handler: The handler to invoke.
    public init(title: String, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension InfoViewAction {
    func toUIAction(dismissing playerViewController: AVPlayerViewController) -> UIAction? {
        UIAction(title: title, image: image) { _ in
            playerViewController.dismiss(animated: true)
            handler()
        }
    }
}
