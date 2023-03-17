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
    private struct IgnoredSafeAreaInInteractionView: View {
        @State private var isInteracting = false

        var body: some View {
            InteractionView(isInteracting: $isInteracting) {
                ZStack {
                    Color.red
                        .ignoresSafeArea()
                    Color.blue
                    Text(isInteracting ? "Interacting" : "Not interacting")
                }
            }
        }
    }

    private struct IgnoredSafeAreaInZStack: View {
        var body: some View {
            ZStack {
                Color.red
                    .ignoresSafeArea()
                Color.blue
            }
        }
    }

    private struct SafeAreaInInteractionView: View {
        @State private var isInteracting = false

        var body: some View {
            InteractionView(isInteracting: $isInteracting) {
                Color.red
                Color.blue
                Text(isInteracting ? "Interacting" : "Not interacting")
            }
        }
    }

    private struct SafeAreaInZStack: View {
        var body: some View {
            ZStack {
                Color.red
                Color.blue
            }
        }
    }

    static var previews: some View {
        IgnoredSafeAreaInInteractionView()
            .previewDisplayName("Safe area ignored in InteractionView")
        IgnoredSafeAreaInZStack()
            .previewDisplayName("Safe area ignored in ZStack")
        SafeAreaInInteractionView()
            .previewDisplayName("Safe area in InteractionView")
        SafeAreaInZStack()
            .previewDisplayName("Safe area in ZStack")
    }
}
