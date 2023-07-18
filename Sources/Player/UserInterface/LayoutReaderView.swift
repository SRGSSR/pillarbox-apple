//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// An internal view controller which can determine whether it covers its current context or is full screen.
@available(tvOS, unavailable)
final class LayoutReaderViewController: UIViewController, UIGestureRecognizerDelegate {
    var layoutInfo: Binding<LayoutInfo> = .constant(.none)
    private var isTransitioning = false

    private static func parent(for viewController: UIViewController) -> UIViewController {
        if let parentViewController = viewController.parent {
            return parent(for: parentViewController)
        }
        else {
            return viewController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutInfo()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isTransitioning = true
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.isTransitioning = false
        }
    }

    private func updateLayoutInfo() {
        guard !isTransitioning else { return }

        let frame = view.frame

        let parentFrame = Self.parent(for: self).view.frame
        let screenFrame = view.window?.windowScene?.screen.bounds ?? .zero

        layoutInfo.wrappedValue = .init(
            isOverCurrentContext: frame == parentFrame,
            isFullScreen: frame == screenFrame
        )
    }
}

@available(tvOS, unavailable)
struct LayoutReaderView: UIViewControllerRepresentable {
    @Binding private var layoutInfo: LayoutInfo

    init(layoutInfo: Binding<LayoutInfo>) {
        _layoutInfo = layoutInfo
    }

    func makeUIViewController(context: Context) -> LayoutReaderViewController {
        .init()
    }

    func updateUIViewController(_ uiViewController: LayoutReaderViewController, context: Context) {
        uiViewController.layoutInfo = _layoutInfo
    }
}
