//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A view which is able to determine whether interaction occurs with its content. The view lays out its children
/// like a `ZStack`.
@available(tvOS, unavailable)
public struct InteractionView<Content: View>: View {
    @Binding private var isInteracting: Bool
    private let action: () -> Void
    @Binding private var content: () -> Content

    public var body: some View {
        // Ignore the safe area to have support for safe area insets similar to a `ZStack`.
        InteractionHostView(isInteracting: _isInteracting, action: action) {
            ZStack {
                content()
            }
        }
        .ignoresSafeArea()
    }

    /// Create the interaction view.
    /// - Parameters:
    ///   - isInteracting: A binding to a Boolean indicating whether the user is currently interacting with the view.
    ///   - action: The action to trigger when user interaction is detected.
    ///   - content: The wrapped content.
    public init(isInteracting: Binding<Bool> = .constant(false), action: @escaping () -> Void = {}, @ViewBuilder content: @escaping () -> Content) {
        _isInteracting = isInteracting
        self.action = action
        _content = .constant(content)
    }
}

@available(tvOS, unavailable)
struct InteractionView_Previews: PreviewProvider {
    static var previews: some View {
        InteractionView(isInteracting: .constant(false)) {
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

        InteractionView(isInteracting: .constant(false)) {
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
