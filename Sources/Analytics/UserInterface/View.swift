//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private final class TrackerViewController: UIViewController, PageViewTracking {
    let commandersActPageView: CommandersActPageView

    init(commandersAct: CommandersActPageView) {
        commandersActPageView = commandersAct
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct PageTrackingView: UIViewControllerRepresentable {
    let commandersAct: CommandersActPageView

    func makeUIViewController(context: Context) -> TrackerViewController {
        TrackerViewController(commandersAct: commandersAct)
    }

    func updateUIViewController(_ uiViewController: TrackerViewController, context: Context) {}
}

public extension View {
    /// Ensures page views are automatically tracked for the receiver.
    ///
    /// A page view will be automatically emitted when:
    /// - The receiver appears on screen.
    /// - The application returns from background with the receiver visible.
    func tracked(commandersAct: CommandersActPageView) -> some View {
        background {
            PageTrackingView(commandersAct: commandersAct)
                .allowsHitTesting(false)
        }
    }
}
