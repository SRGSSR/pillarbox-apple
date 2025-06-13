//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

@propertyWrapper private class ControlReference {
    fileprivate weak var control: UIControl?

    var wrappedValue: ControlReference {
        self
    }

    func sendAction() {
        control?.sendActions(for: .touchUpInside)
    }
}

private struct RoutePickerWrapper: UIViewRepresentable {
    let reference: ControlReference

    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.isHidden = true
        return view
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        guard let button = uiView.subviews.first(where: { $0 is UIButton }) as? UIButton else { return }
        reference.control = button
    }
}

private struct RoutePickerMenuContent: View {
    @ControlReference private var reference

    var body: some View {
        SwiftUI.Button(action: sendAction) {
            Label("AirPlay", systemImage: "airplay.video")
                .background {
                    RoutePickerWrapper(reference: reference)
                }
        }
    }

    private func sendAction() {
        reference.sendAction()
    }
}

public extension RoutePickerView {
    static func routePickerMenu() -> some View {
        RoutePickerMenuContent()
    }
}
