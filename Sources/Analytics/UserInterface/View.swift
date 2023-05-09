//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private final class TrackerViewController: UIViewController, PageViewTracking {
    let pageTitle: String
    let pageLevels: [String]

    init(pageTitle: String, pageLevels: [String]) {
        self.pageTitle = pageTitle
        self.pageLevels = pageLevels
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct PageTrackingView: UIViewControllerRepresentable {
    let title: String
    let levels: [String]

    func makeUIViewController(context: Context) -> TrackerViewController {
        TrackerViewController(pageTitle: title, pageLevels: levels)
    }

    func updateUIViewController(_ uiViewController: TrackerViewController, context: Context) {}
}

public extension View {
    func tracked(title: String, levels: [String] = []) -> some View {
        ZStack {
            PageTrackingView(title: title, levels: levels)
            self
        }
    }
}
