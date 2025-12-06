import UIKit

public protocol InfoViewActionsBody {
    func toAction(dismissing viewController: UIViewController) -> UIAction
}

public struct InfoViewActionsBodyNotSupported: InfoViewActionsBody {
    public func toAction(dismissing viewController: UIViewController) -> UIAction {
        fatalError()
    }
}
