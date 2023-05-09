//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import SwiftUI

struct AnalyticsPageView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AnalyticsPageViewController {
        .init()
    }

    func updateUIViewController(_ uiViewController: AnalyticsPageViewController, context: Context) {}
}

final class AnalyticsPageViewController: UIViewController, PageViewTracking {
    let pageTitle = "Analytics"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
