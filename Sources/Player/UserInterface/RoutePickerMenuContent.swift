//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

@propertyWrapper private class Control {
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

private struct RoutePickerMenuContent: View {
    @Control private var control

    var body: some View {
        SwiftUI.Button(action: sendAction) {
            Label("AirPlay", systemImage: "airplay.video")
                .background {
                    RoutePickerWrapper(control: control)
                }
        }
    }

    private func sendAction() {
        control.sendAction()
    }
}

public extension RoutePickerView {
    static func routePickerMenu() -> some View {
        RoutePickerMenuContent()
    }
}
