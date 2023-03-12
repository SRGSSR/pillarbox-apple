//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Core
import SwiftUI

/// An internal host controller detecting user interaction in its content view.
@available(tvOS, unavailable)
public final class _InteractionHostingController<Content: View>: UIHostingController<Content>, UIGestureRecognizerDelegate {
    var action: (() -> Void)?

    override public func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = ActivityGestureRecognizer(target: self, action: #selector(reportActivity(_:)))
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Fix incorrect frame so that wrapped content can correctly extend beyond the safe area when required to.
        if let superview = view.superview, let parent = superview.superview {
            superview.frame = parent.bounds
        }
    }

    public func gestureRecognizer(
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

/// A view detecting triggering an associated action when any kind of touch interaction happens with its content.
@available(tvOS, unavailable)
public struct InteractionView<Content: View>: UIViewRepresentable {
    private let action: () -> Void
    @Binding private var content: () -> Content

    /// Create the interaction view.
    /// - Parameters:
    ///   - action: The action to trigger when user interaction is detected.
    ///   - content: The wrapped content.
    public init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        _content = .constant(content)
    }

    public func makeCoordinator() -> _InteractionHostingController<Content> {
        _InteractionHostingController(rootView: content())
    }

    public func makeUIView(context: Context) -> UIView {
        let hostView = context.coordinator.view!
        hostView.backgroundColor = .clear
        return hostView
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        let hostController = context.coordinator
        hostController.rootView = content()
        hostController.action = action
        uiView.applySizingBehavior(of: hostController)
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
        InteractionView(action: {}) {
            Color.red
        }
        InteractionView(action: {}) {
            ZStack {
                Color.red
            }
        }
    }
}
