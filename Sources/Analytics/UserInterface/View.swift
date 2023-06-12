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
    /// Ensures page views are automatically tracked for the receiver.
    ///
    /// A page view will be automatically emitted when:
    ///
    /// - The receiver appears on screen.
    /// - The application returns from background with the receiver visible.
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
