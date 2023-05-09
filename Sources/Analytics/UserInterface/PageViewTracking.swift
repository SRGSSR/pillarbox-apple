//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol PageViewTracking {
    var pageTitle: String { get }
    var pageLevels: [String] { get }
    var isTrackedAutomatically: Bool { get }
}

public extension PageViewTracking {
    var pageLevels: [String] {
        []
    }

    var isTrackedAutomatically: Bool {
        true
    }
}

extension UIViewController {
    static func setupTracking() {
        method_exchangeImplementations(
            class_getInstanceMethod(Self.self, #selector(viewDidAppear(_:)))!,
            class_getInstanceMethod(Self.self, #selector(swizzledViewDidAppear(_:)))!
        )
    }

    @objc func swizzledViewDidAppear(_ animated: Bool) {
        swizzledViewDidAppear(animated)
    }
}
