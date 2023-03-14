//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// An internal host controller which can determine if it is maximized in its parent context.
@available(tvOS, unavailable)
final class LayoutReaderHostingController<Content: View>: UIHostingController<Content>, UIGestureRecognizerDelegate {
    var isMaximized: Binding<Bool> = .constant(false)

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
        isMaximized.wrappedValue = frame == parentFrame
    }
}

@available(tvOS, unavailable)
struct LayoutReaderHost<Content: View>: UIViewControllerRepresentable {
    @Binding private var isMaximized: Bool
    @Binding private var content: () -> Content

    init(isMaximized: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        _isMaximized = isMaximized
        _content = .constant(content)
    }

    // Return a `UIHostingController` directly to ensure correct safe area insets
    func makeUIViewController(context: Context) -> LayoutReaderHostingController<Content> {
        LayoutReaderHostingController(rootView: content())
    }

    func updateUIViewController(_ uiViewController: LayoutReaderHostingController<Content>, context: Context) {
        uiViewController.rootView = content()
        uiViewController.isMaximized = _isMaximized
    }
}
