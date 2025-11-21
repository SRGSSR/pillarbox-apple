//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import UIKit

/// An action presented by ``SystemVideoView``.
public struct SystemVideoViewAction {
    private let title: String
    private let image: UIImage?
    private let identifier: UIAction.Identifier
    private let handler: () -> Void

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: Short display title.
    ///   - image: Image that can appear next to this action.
    ///   - identifier: A unique identifier for the action.
    ///   - handler: The handler to invoke.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, identifier: UIAction.Identifier, handler: @escaping () -> Void) where S: StringProtocol {
        self.title = String(title)
        self.image = image
        self.identifier = identifier
        self.handler = handler
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: Short display title.
    ///   - image: Image that can appear next to this action.
    ///   - identifier: A unique identifier for the action.
    ///   - handler: The handler to invoke.
    public init(title: LocalizedStringResource, image: UIImage? = nil, identifier: UIAction.Identifier, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, identifier: identifier, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: Short display title.
    ///   - systemImage: System image name that can appear next to this action.
    ///   - identifier: A unique identifier for the action.
    ///   - handler: The handler to invoke.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, identifier: UIAction.Identifier, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), identifier: identifier, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: Short display title.
    ///   - systemImage: System image name that can appear next to this action.
    ///   - identifier: A unique identifier for the action.
    ///   - handler: The handler to invoke.
    public init(title: LocalizedStringResource, systemImage: String, identifier: UIAction.Identifier, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage), identifier: identifier, handler: handler)
    }
}

extension SystemVideoViewAction {
    func toContextualAction() -> UIAction {
        UIAction(title: title, image: image, identifier: identifier) { _ in
            handler()
        }
    }

    func toInfoViewAction(dismissing playerViewController: AVPlayerViewController) -> UIAction {
        UIAction(title: title, image: image, identifier: identifier) { [weak playerViewController] _ in
            playerViewController?.dismiss(animated: true)
            handler()
        }
    }
}
