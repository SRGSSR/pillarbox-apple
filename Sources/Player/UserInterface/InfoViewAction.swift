//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// Action which show up in the info tab.
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

extension UIAction {
    static func from(_ action: InfoViewAction) -> UIAction {
        UIAction(title: action.title, image: action.image, identifier: .init(rawValue: action.title)) { _ in
            action.handler()
        }
    }
}
