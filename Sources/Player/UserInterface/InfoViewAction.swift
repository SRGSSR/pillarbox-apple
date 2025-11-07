//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// Represents a single action displayed in the info view of a tvOS player.
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
}

extension InfoViewAction {
    func toUIAction() -> UIAction {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in
            handler()
        }
    }
}
