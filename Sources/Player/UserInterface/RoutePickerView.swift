//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

private struct _RoutePickerView: UIViewRepresentable {
    let prioritizesVideoDevices: Bool
    let activeTintColor: Color?

    func makeUIView(context: Context) -> AVRoutePickerView {
        AVRoutePickerView()
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        uiView.prioritizesVideoDevices = prioritizesVideoDevices
        if let activeTintColor {
            uiView.activeTintColor = UIColor(activeTintColor)
        }
    }
}

/// A button to pick a playback route independently of a player.
///
/// This view represents a button that users tap to stream audio/video content to a media receiver, such as a Mac or
/// Apple TV. When the user taps the button, the system presents a popover that displays all of the nearby AirPlay
/// devices that can receive and play back media. If your app prefers video content, the system displays video-capable
/// devices higher in the list.
///
/// > Important: This button is not available for iPad applications run on macOS or using Catalyst.
public struct RoutePickerView: View {
    private var prioritizesVideoDevices: Bool
    private var activeTintColor: Color?

    // swiftlint:disable:next missing_docs
    public var body: some View {
        if !ProcessInfo.processInfo.isRunningOnMac {
            _RoutePickerView(prioritizesVideoDevices: prioritizesVideoDevices, activeTintColor: activeTintColor)
        }
        else {
            EmptyView()
        }
    }

    /// Creates a route picker button.
    ///
    /// - Parameter prioritizesVideoDevices: A Boolean setting whether or not the route picker should sort video
    ///   capable output devices to the top of the list. Setting this to `true` will cause the route picker view to
    ///   show a videocentric icon.
    public init(prioritizesVideoDevices: Bool = false) {
        self.prioritizesVideoDevices = prioritizesVideoDevices
    }
}

public extension RoutePickerView {
    /// Sets the view's tint color to apply when AirPlay is active.
    ///
    /// - Parameter color: The color to apply.
    /// - Returns: The view tinted with the specified color.
    func activeTintColor(_ color: Color) -> RoutePickerView {
        var view = self
        view.activeTintColor = color
        return view
    }
}

#Preview("Audio") {
    RoutePickerView()
}

#Preview("Video") {
    RoutePickerView(prioritizesVideoDevices: true)
}
