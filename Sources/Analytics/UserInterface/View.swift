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
    /// Ensure a page view is sent for the receiver when it appears on screen, or when the application returns from
    /// background with the view visible.
    /// - Parameters:
    ///   - title: The page title.
    ///   - levels: Page levels.
    func tracked(title: String, levels: [String] = []) -> some View {
        background {
            PageTrackingView(title: title, levels: levels)
                .allowsHitTesting(false)
        }
    }
}

struct TrackedView_Previews: PreviewProvider {
    static var previews: some View {
        Color.red
            .frame(width: 40, height: 40)
            .tracked(title: "title")
            .border(Color.blue)
    }
}
