//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol InfoViewAction: UIInfoViewActionConvertible {}

public protocol UIInfoViewActionConvertible {
    func toUIAction(dismissing viewController: UIViewController) -> UIAction
}
