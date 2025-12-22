//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A type that describing the content displayed in a custom info view controller on tvOS.
public struct CustomInfoView {
    let title: String
    let view: AnyView

    /// Creates a new `Self` instance
    /// - Parameters:
    ///   - title: The title of the custom info view.
    ///   - views: A `ViewBuilder` closure that provides the SwiftUI view to be displayed inside the custom info view controller.
    public init(title: String, @ViewBuilder _ views: () -> some View) {
        self.title = title
        self.view = AnyView(views())
    }
}
