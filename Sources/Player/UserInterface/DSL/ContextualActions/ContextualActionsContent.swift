//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that describing the content of contextual actions.
public struct ContextualActionsContent {
    private let children: [any ContextualActionsElement]

    init(children: [any ContextualActionsElement] = []) {
        self.children = children
    }

    func toActions() -> [UIAction] {
        children.map { $0.toAction() }
    }
}
