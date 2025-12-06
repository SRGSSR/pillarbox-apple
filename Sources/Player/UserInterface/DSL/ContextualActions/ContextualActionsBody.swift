import UIKit

public protocol ContextualActionsBody {
    func toAction() -> UIAction
}

public struct ContextualActionsBodyNotSupported: ContextualActionsBody {
    public func toAction() -> UIAction {
        fatalError()
    }
}
