//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol InfoViewActionsElement {
    associatedtype Body: InfoViewActionsBody

    var body: Body { get }
}

extension InfoViewActionsElement {
    func toAction(dismissing viewController: UIViewController) -> UIAction {
        body.toAction(dismissing: viewController)
    }
}
