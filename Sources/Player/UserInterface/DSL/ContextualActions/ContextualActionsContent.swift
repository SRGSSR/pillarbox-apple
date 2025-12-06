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
