//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

@propertyWrapper
private class Control {
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

struct RoutePickerMenuContent: View {
    private static let defaultActiveTintColor: Color = {
        guard let color = AVRoutePickerView().activeTintColor else { return .blue }
        return .init(uiColor: color)
    }()

    let activeTintColor: Color?
    @ObservedObject var player: Player

    @Control private var control

    var body: some View {
        SwiftUI.Button(action: sendAction) {
            Label {
                Text(verbatim: "AirPlay")
            } icon: {
                icon()
            }
            .background {
                RoutePickerWrapper(control: control)
            }
        }
    }

    private var foregroundColor: Color {
        activeTintColor ?? Self.defaultActiveTintColor
    }

    @ViewBuilder
    private func icon() -> some View {
        if player.isExternalPlaybackActive {
            Image(systemName: "airplay.video")
                .symbolRenderingMode(.palette)
                .foregroundStyle(foregroundColor, foregroundColor.opacity(0.5))
        }
        else {
            Image(systemName: "airplay.video")
        }
    }

    private func sendAction() {
        control.sendAction()
    }
}
