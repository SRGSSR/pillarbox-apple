//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that describing the content of contextual actions.
public struct ContextualActionsContent {
    private let elements: [any ContextualActionsElement]

    init(elements: [any ContextualActionsElement] = []) {
        self.elements = elements
    }

    func toActions() -> [UIAction] {
        elements.map { $0.toAction() }
    }
}
