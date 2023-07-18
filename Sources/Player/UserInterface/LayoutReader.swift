//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// Layout information.
public struct LayoutInfo {
    /// A placeholder for unfilled layout information.
    public static var none: Self {
        .init(isOverCurrentContext: false, isFullScreen: false)
    }

    /// A Boolean describing whether the view covers its current context.
    public let isOverCurrentContext: Bool

    /// A Boolean describing whether the view covers the whole screen.
    public let isFullScreen: Bool
}

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
private struct LayoutReader: UIViewControllerRepresentable {
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

@available(tvOS, unavailable)
public extension View {
    /// Read layout information.
    /// 
    /// - Parameter layoutInfo: The layout information.
    func readLayout(into layoutInfo: Binding<LayoutInfo>) -> some View {
        background {
            LayoutReader(layoutInfo: layoutInfo)
                .ignoresSafeArea()
        }
    }
}

@available(tvOS, unavailable)
struct LayoutReader_Previews: PreviewProvider {
    private struct IgnoredSafeArea: View {
        @State private var layoutInfo: LayoutInfo = .none

        var body: some View {
            ZStack {
                Color.red
                    .ignoresSafeArea()
                Color.blue
                VStack {
                    Text(layoutInfo.isOverCurrentContext ? "✅ Over current context" : "❌ Not over current context")
                    Text(layoutInfo.isFullScreen ? "✅ Full screen" : "❌ Not full screen")
                }
            }
            .readLayout(into: $layoutInfo)
        }
    }

    private struct SafeArea: View {
        @State private var layoutInfo: LayoutInfo = .none

        var body: some View {
            ZStack {
                Color.red
                Color.blue
                VStack {
                    Text(layoutInfo.isOverCurrentContext ? "✅ Over current context" : "❌ Not over current context")
                    Text(layoutInfo.isFullScreen ? "✅ Full screen" : "❌ Not full screen")
                }
            }
            .readLayout(into: $layoutInfo)
        }
    }

    private struct NotOverCurrentContext: View {
        @State private var layoutInfo: LayoutInfo = .none

        var body: some View {
            ZStack {
                Color.blue
                VStack {
                    Text(layoutInfo.isOverCurrentContext ? "❌ Over current context" : "✅ Not over current context")
                    Text(layoutInfo.isFullScreen ? "❌ Full screen" : "✅ Not full screen")
                }
            }
            .frame(width: 400, height: 400)
            .readLayout(into: $layoutInfo)
        }
    }

    private struct NonFullScreen: View {
        @State private var layoutInfo: LayoutInfo = .none

        var body: some View {
            Color.yellow
                .sheet(isPresented: .constant(true)) {
                    ZStack {
                        Color.blue
                        VStack {
                            Text(layoutInfo.isOverCurrentContext ? "✅ Over current context" : "❌ Not over current context")
                            Text(layoutInfo.isFullScreen ? "❌ Full screen" : "✅ Not full screen")
                        }
                    }
                    .interactiveDismissDisabled()
                    .readLayout(into: $layoutInfo)
                }
        }
    }

    static var previews: some View {
        IgnoredSafeArea()
            .previewDisplayName("Safe area ignored in LayoutReader")
        SafeArea()
            .previewDisplayName("Safe area in LayoutReader")
        NotOverCurrentContext()
            .previewDisplayName("Not over current context LayoutReader")
        NonFullScreen()
            .previewDisplayName("Non full-screen LayoutReader")
    }
}
