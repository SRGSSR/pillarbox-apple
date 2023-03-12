//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Core
import SwiftUI

public final class InteractionHostingController<Content: View>: UIHostingController<Content>, UIGestureRecognizerDelegate {
    var action: (() -> Void)?

    override public func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = ActivityGestureRecognizer(target: self, action: #selector(reportActivity(_:)))
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
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

public struct InteractionView<Content: View>: UIViewRepresentable {
    private let action: () -> Void
    @Binding private var content: () -> Content

    public init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        _content = .constant(content)
    }

    public func makeCoordinator() -> InteractionHostingController<Content> {
        InteractionHostingController(rootView: content())
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
