//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public struct ContextualActionsContent {
    private let children: [any ContextualActionsElement]

    init(children: [any ContextualActionsElement] = []) {
        self.children = children
    }

    func toActions() -> [UIAction] {
        children.map { $0.toAction() }
    }
}
