//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

/// A button to pick a playback route.
public struct RoutePickerView: UIViewRepresentable {
    public init() {}

    public func makeUIView(context: Context) -> AVRoutePickerView {
        AVRoutePickerView()
    }

    public func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
