//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol ContainerPageViewTracking {
    var activeChildren: [UIViewController] { get }
}

extension UINavigationController: ContainerPageViewTracking {
    public var activeChildren: [UIViewController] {
        guard let topViewController else { return [] }
        return [topViewController]
    }
}
