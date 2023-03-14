//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// An internal host controller detecting user interaction in its content view.
@available(tvOS, unavailable)
final class InteractionHostingController<Content: View>: UIHostingController<Content>, UIGestureRecognizerDelegate {
    var isInteracting: Binding<Bool> = .constant(false)
    var action: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        configureGestureRecognizer()
    }

    private func configureGestureRecognizer() {
        let gestureRecognizer = ActivityGestureRecognizer(target: self, action: #selector(reportActivity(_:)))
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer:
        UIGestureRecognizer
    ) -> Bool {
        true
    }

    @objc
    private func reportActivity(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            isInteracting.wrappedValue = true
            action?()
        case .changed:
            action?()
        default:
            isInteracting.wrappedValue = false
        }
    }
}

@available(tvOS, unavailable)
struct InteractionHostView<Content: View>: UIViewControllerRepresentable {
    @Binding private var isInteracting: Bool
    private let action: () -> Void
    @Binding private var content: () -> Content

    init(isInteracting: Binding<Bool>, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        _isInteracting = isInteracting
        self.action = action
        _content = .constant(content)
    }

    // Return a `UIHostingController` directly to ensure correct safe area insets
    func makeUIViewController(context: Context) -> InteractionHostingController<Content> {
        InteractionHostingController(rootView: content())
    }

    func updateUIViewController(_ uiViewController: InteractionHostingController<Content>, context: Context) {
        uiViewController.rootView = content()
        uiViewController.isInteracting = _isInteracting
        uiViewController.action = action
    }
}
