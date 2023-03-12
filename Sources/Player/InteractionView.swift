//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Core
import SwiftUI

/// An internal host controller detecting user interaction in its content view.
@available(tvOS, unavailable)
private final class InteractionHostingController<Content: View>: UIHostingController<Content>, UIGestureRecognizerDelegate {
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
        action?()
    }
}

@available(tvOS, unavailable)
private struct _InteractionView<Content: View>: UIViewControllerRepresentable {
    private let action: () -> Void
    @Binding private var content: () -> Content

    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        _content = .constant(content)
    }

    // Return a `UIHostingController` directly to ensure correct safe area insets
    func makeUIViewController(context: Context) -> InteractionHostingController<Content> {
        InteractionHostingController(rootView: content())
    }

    func updateUIViewController(_ uiViewController: InteractionHostingController<Content>, context: Context) {
        uiViewController.rootView = content()
        uiViewController.action = action
    }
}

/// A view triggering an action when any kind of touch interaction happens with its content.
@available(tvOS, unavailable)
public struct InteractionView<Content: View>: View {
    private let action: () -> Void
    @Binding private var content: () -> Content

    public var body: some View {
        // Ignore the safe area to have support for safe area insets similar to a `ZStack`.
        _InteractionView(action: action, content: content)
            .ignoresSafeArea()
    }

    /// Create the interaction view.
    /// - Parameters:
    ///   - action: The action to trigger when user interaction is detected.
    ///   - content: The wrapped content.
    public init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        _content = .constant(content)
    }
}

@available(tvOS, unavailable)
struct InteractionView_Previews: PreviewProvider {
    static var previews: some View {
        InteractionView(action: {}) {
            ZStack {
                Color.red
                    .ignoresSafeArea()
                Color.blue
            }
        }
        .previewDisplayName("Safe area ignored in InteractionView")

        ZStack {
            Color.red
                .ignoresSafeArea()
            Color.blue
        }
        .previewDisplayName("Safe area ignored in ZStack")

        InteractionView(action: {}) {
            Color.red
        }
        .previewDisplayName("Simple InteractionView")

        ZStack {
            Color.red
        }
        .previewDisplayName("Simple ZStack")
    }
}
