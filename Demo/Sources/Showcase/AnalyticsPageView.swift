//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import SwiftUI

struct AnalyticsPageView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        .init(rootViewController: AnalyticsPageViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

final class AnalyticsPageViewController: UIViewController, PageViewTracking {
    let pageTitle = "Analytics"

    override var title: String? {
        get {
            "Analytics"
        }
        set {}
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
