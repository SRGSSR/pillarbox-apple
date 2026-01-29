//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

@propertyWrapper
private final class Control {
    fileprivate weak var source: UIControl?

    var wrappedValue: Control {
        self
    }

    func sendAction() {
        source?.sendActions(for: .touchUpInside)
    }
}

private struct RoutePickerWrapper: UIViewRepresentable {
    let control: Control

    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.isHidden = true
        return view
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        guard let button = uiView.subviews.first(where: { $0 is UIButton }) as? UIButton else { return }
        control.source = button
    }
}

private struct _RoutePickerButton<Content>: View where Content: View {
    let content: () -> Content

    @Control private var control

    var body: some View {
        SwiftUI.Button(action: sendAction) {
            content()
                .background {
                    RoutePickerWrapper(control: control)
                }
        }
    }

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    private func sendAction() {
        control.sendAction()
    }
}

/// A button to pick a playback route.
///
/// > Important: This button is not available for iPad applications run on macOS or using Catalyst.
public struct RoutePickerButton<Content>: View where Content: View {
    let content: () -> Content

    // swiftlint:disable:next missing_docs
    public var body: some View {
        if !ProcessInfo.processInfo.isRunningOnMac {
            _RoutePickerButton(content: content)
        }
        else {
            EmptyView()
        }
    }

    /// Creates a route picker button.
    ///
    /// - Parameter content: The content displayed by the button.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}


