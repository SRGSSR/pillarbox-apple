//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

extension UIViewController {
    func isMovingToParentOrBeingPresented() -> Bool {
        if isMovingToParent || isBeingPresented {
            return true
        }
        else if let parent {
            return parent.isMovingToParentOrBeingPresented()
        }
        else {
            return false
        }
    }
}
