//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

extension UIViewController {
    static func setupTracking() {
        method_exchangeImplementations(
            class_getInstanceMethod(Self.self, #selector(viewDidAppear(_:)))!,
            class_getInstanceMethod(Self.self, #selector(swizzledViewDidAppear(_:)))!
        )
    }

    @objc func swizzledViewDidAppear(_ animated: Bool) {
        swizzledViewDidAppear(animated)
        guard let trackedViewController = self as? PageViewTracking, trackedViewController.isTrackedAutomatically else { return }
        Analytics.shared.sendPageView(title: trackedViewController.pageTitle, levels: trackedViewController.pageLevels)
    }
}
