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

/// A button to pick a playback route.
///
/// > Important: This button is not available for iPad applications run on macOS or using Catalyst.
public struct RoutePickerButton<Content>: View where Content: View {
    @ObservedObject var player: Player
    let content: (Bool) -> Content

    @Control private var control

    // swiftlint:disable:next missing_docs
    public var body: some View {
        SwiftUI.Button(action: sendAction) {
            content(player.isExternalPlaybackActive)
                .background {
                    RoutePickerWrapper(control: control)
                }
        }
    }

    /// Creates a route picker button.
    ///
    /// - Parameters:
    ///   - player: A player whose external playback state must be reflected by the button.
    ///   - content: The content displayed in the button.
    public init(player: Player, @ViewBuilder content: @escaping (_ isExternalPlaybackActive: Bool) -> Content) {
        self.player = player
        self.content = content
    }

    private func sendAction() {
        control.sendAction()
    }
}
