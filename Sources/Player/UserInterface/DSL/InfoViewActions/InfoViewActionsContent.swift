import UIKit

public struct InfoViewActionsContent {
    private let children: [any InfoViewActionsElement]

    init(children: [any InfoViewActionsElement] = []) {
        self.children = children
    }

    func toActions(dismissing viewController: UIViewController) -> [UIAction] {
        children.map { $0.toAction(dismissing: viewController) }
    }
}
