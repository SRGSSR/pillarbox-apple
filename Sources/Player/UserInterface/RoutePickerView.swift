//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

/// A button to pick a playback route.
///
/// Behavior: h-exp, v-exp
public struct RoutePickerView: UIViewRepresentable {
    private var prioritizesVideoDevices: Bool
    fileprivate var activeTintColor: Color?

    /// Creates a route picker button.
    ///
    /// - Parameter prioritizesVideoDevices: A Boolean setting whether or not the route picker should sort video
    ///   capable output devices to the top of the list. Setting this to `true` will cause the route picker view to
    ///   show a videocentric icon.
    public init(prioritizesVideoDevices: Bool = false) {
        self.prioritizesVideoDevices = prioritizesVideoDevices
    }

    public func makeUIView(context: Context) -> AVRoutePickerView {
        AVRoutePickerView()
    }

    public func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        uiView.prioritizesVideoDevices = prioritizesVideoDevices
        if let activeTintColor {
            uiView.activeTintColor = UIColor(activeTintColor)
        }
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

struct RoutePickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoutePickerView()
            RoutePickerView(prioritizesVideoDevices: true)
        }
        .previewLayout(.fixed(width: 45, height: 45))
    }
}
