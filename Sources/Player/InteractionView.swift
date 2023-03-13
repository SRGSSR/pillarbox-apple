//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A view triggering an action when any kind of touch interaction happens with its content. The view layout its
/// children like a `ZStack`.
@available(tvOS, unavailable)
public struct InteractionView<Content: View>: View {
    private let action: () -> Void
    @Binding private var content: () -> Content

    public var body: some View {
        // Ignore the safe area to have support for safe area insets similar to a `ZStack`.
        InteractionHostView(action: action) {
            ZStack {
                content()
            }
        }
        .ignoresSafeArea()
    }

    /// Create the interaction view.
    /// - Parameters:
    ///   - action: The action to trigger when user interaction is detected.
    ///   - content: The wrapped content.
    public init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        _content = .constant(content)
    }
}

@available(tvOS, unavailable)
struct InteractionView_Previews: PreviewProvider {
    static var previews: some View {
        InteractionView(action: {}) {
            ZStack {
                Color.red
                    .ignoresSafeArea()
                Color.blue
            }
        }
        .previewDisplayName("Safe area ignored in InteractionView")

        ZStack {
            Color.red
                .ignoresSafeArea()
            Color.blue
        }
        .previewDisplayName("Safe area ignored in ZStack")

        InteractionView(action: {}) {
            Color.red
            Color.blue
        }
        .previewDisplayName("Simple InteractionView")

        ZStack {
            Color.red
            Color.blue
        }
        .previewDisplayName("Simple ZStack")
    }
}
