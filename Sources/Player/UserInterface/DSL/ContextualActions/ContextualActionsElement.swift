import UIKit

public protocol ContextualActionsElement {
    associatedtype Body: ContextualActionsBody

    var body: Body { get }
}

extension ContextualActionsElement {
    func toAction() -> UIAction {
        body.toAction()
    }
}
