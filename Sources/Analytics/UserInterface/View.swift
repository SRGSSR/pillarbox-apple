//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private final class TrackerViewController: UIViewController, PageViewTracking {
    let comScorePageView: ComScorePageView
    let commandersActPageView: CommandersActPageView

    init(comScore: ComScorePageView, commandersAct: CommandersActPageView) {
        comScorePageView = comScore
        commandersActPageView = commandersAct
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct PageTrackingView: UIViewControllerRepresentable {
    let comScore: ComScorePageView
    let commandersAct: CommandersActPageView

    func makeUIViewController(context: Context) -> TrackerViewController {
        TrackerViewController(comScore: comScore, commandersAct: commandersAct)
    }

    func updateUIViewController(_ uiViewController: TrackerViewController, context: Context) {}
}

public extension View {
    /// Ensures page views are automatically tracked for the receiver.
    ///
    /// A page view will be automatically emitted when:
    /// - The receiver appears on screen.
    /// - The application returns from background with the receiver visible.
    func tracked(comScore: ComScorePageView, commandersAct: CommandersActPageView) -> some View {
        background {
            PageTrackingView(comScore: comScore, commandersAct: commandersAct)
                .allowsHitTesting(false)
        }
    }
}
