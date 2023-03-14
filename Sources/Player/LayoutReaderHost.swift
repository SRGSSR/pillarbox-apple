//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// An internal host controller which can determine if it is maximized in its parent context.
@available(tvOS, unavailable)
final class LayoutReaderHostingController<Content: View>: UIHostingController<Content>, UIGestureRecognizerDelegate {
    var layoutInfo: Binding<LayoutInfo> = .constant(.none)

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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let frame = view.frame

        let parentFrame = Self.parent(for: self).view.frame
        let screenFrame = view.window?.windowScene?.screen.bounds ?? .zero

        layoutInfo.wrappedValue = .init(
            isMaximized: frame == parentFrame,
            isFullScreen: frame == screenFrame
        )
    }
}

@available(tvOS, unavailable)
struct LayoutReaderHost<Content: View>: UIViewControllerRepresentable {
    @Binding private var layoutInfo: LayoutInfo
    @Binding private var content: () -> Content

    init(layoutInfo: Binding<LayoutInfo>, @ViewBuilder content: @escaping () -> Content) {
        _layoutInfo = layoutInfo
        _content = .constant(content)
    }

    // Return a `UIHostingController` directly to ensure correct safe area insets
    func makeUIViewController(context: Context) -> LayoutReaderHostingController<Content> {
        LayoutReaderHostingController(rootView: content())
    }

    func updateUIViewController(_ uiViewController: LayoutReaderHostingController<Content>, context: Context) {
        uiViewController.layoutInfo = _layoutInfo
        uiViewController.rootView = content()
    }
}
