//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import UIKit

/// Actions to present contextually during playback.
public struct InfoViewAction {
    private let title: String
    private let image: UIImage?
    private let handler: () -> Void

    /// Creates an info view action.
    ///
    /// - Parameters:
    ///   - title: Short display title.
    ///   - image: Image that can appear next to this action.
    ///   - handler: The handler to invoke.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.title = String(title)
        self.image = image
        self.handler = handler
    }

    /// Creates an info view action.
    ///
    /// - Parameters:
    ///   - title: Short display title.
    ///   - image: Image that can appear next to this action.
    ///   - handler: The handler to invoke.
    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.title = String(localized: title)
        self.image = image
        self.handler = handler
    }

    /// Creates an info view action.
    ///
    /// - Parameters:
    ///   - title: Short display title.
    ///   - systemImage: System image name that can appear next to this action.
    ///   - handler: The handler to invoke.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }

    /// Creates an info view action.
    ///
    /// - Parameters:
    ///   - title: Short display title.
    ///   - systemImage: System image name that can appear next to this action.
    ///   - handler: The handler to invoke.
    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension InfoViewAction {
    func toUIAction(dismissing playerViewController: AVPlayerViewController) -> UIAction {
        UIAction(title: title, image: image) { [weak playerViewController] _ in
            playerViewController?.dismiss(animated: true)
            handler()
        }
    }
}
