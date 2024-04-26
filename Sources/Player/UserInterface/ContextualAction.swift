//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// Actions to present contextually during playback.
public struct ContextualAction {
    /// Short display title.
    public let title: String

    /// Image that can appear next to this action.
    public let image: UIImage?

    /// The action to execute.
    public let handler: () -> Void

    /// Creates a new contextual action.
    ///
    /// - Parameters:
    ///   - title: Short display title.
    ///   - image: Image that can appear next to this action.
    ///   - handler: The action to execute.
    public init(title: String, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.handler = handler
    }
}
