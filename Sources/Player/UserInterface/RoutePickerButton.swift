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
    let prioritizesVideoDevices: Bool
    let control: Control

    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.isHidden = true
        return view
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        uiView.prioritizesVideoDevices = prioritizesVideoDevices
        if let button = uiView.subviews.first(where: { $0 is UIButton }) as? UIButton {
            control.source = button
        }
    }
}

private struct _RoutePickerButton<Content>: View where Content: View {
    let prioritizesVideoDevices: Bool
    let content: () -> Content

    @Control private var control

    var body: some View {
        SwiftUI.Button(action: sendAction) {
            content()
                .background {
                    RoutePickerWrapper(prioritizesVideoDevices: prioritizesVideoDevices, control: control)
                }
        }
    }

    private func sendAction() {
        control.sendAction()
    }
}

/// A button to pick a playback route.
///
/// This view represents a custom button that users tap to stream audio/video content to a media receiver, such as a
/// Mac or Apple TV. When the user taps the button, the system presents a popover that displays all of the nearby AirPlay
/// devices that can receive and play back media. If your app prefers video content, the system displays video-capable
/// devices higher in the list. 
///
/// > Important: This button is not available for iPad applications run on macOS or using Catalyst.
public struct RoutePickerButton<Content>: View where Content: View {
    private let prioritizesVideoDevices: Bool
    let content: () -> Content

    // swiftlint:disable:next missing_docs
    public var body: some View {
        if !ProcessInfo.processInfo.isRunningOnMac {
            _RoutePickerButton(prioritizesVideoDevices: prioritizesVideoDevices, content: content)
        }
        else {
            EmptyView()
        }
    }

    /// Creates a route picker button.
    ///
    /// - Parameters:
    ///   - prioritizesVideoDevices: A Boolean setting whether or not the route picker should sort video capable output
    ///     devices to the top of the list.
    ///   - content: The content displayed by the button.
    public init(prioritizesVideoDevices: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.prioritizesVideoDevices = prioritizesVideoDevices
        self.content = content
    }
}

#Preview("Audio") {
    RoutePickerButton {
        Label("AirPlay", systemImage: "airplay.audio")
    }
}

#Preview("Video") {
    RoutePickerButton(prioritizesVideoDevices: true) {
        Label("AirPlay", systemImage: "airplay.video")
    }
}
