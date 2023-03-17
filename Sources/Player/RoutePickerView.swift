//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

/// A button to pick a playback route.
/// Behavior: h-exp, v-exp
public struct RoutePickerView: UIViewRepresentable {
    private var prioritizesVideoDevices: Bool

    /// Create the button.
    /// - Parameter prioritizesVideoDevices: Whether or not the route picker should sort video capable output devices
    ///   to the top of the list. Setting this to YES will cause the route picker view to show a videocentric icon.
    public init(prioritizesVideoDevices: Bool = false) {
        self.prioritizesVideoDevices = prioritizesVideoDevices
    }

    public func makeUIView(context: Context) -> AVRoutePickerView {
        AVRoutePickerView()
    }

    public func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        uiView.prioritizesVideoDevices = prioritizesVideoDevices
    }
}
