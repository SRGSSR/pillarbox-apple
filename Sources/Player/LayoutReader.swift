//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A view which is able to determine whether it is maximized in its parent context. The view lays out its children
/// like a `ZStack`.
@available(tvOS, unavailable)
public struct LayoutReader<Content: View>: View {
    @Binding private var isMaximized: Bool
    @Binding private var content: () -> Content

    public var body: some View {
        // Ignore the safe area to have support for safe area insets similar to a `ZStack`.
        LayoutReaderHost(isMaximized: _isMaximized) {
            ZStack {
                content()
            }
        }
        .ignoresSafeArea()
    }

    /// Create the layout reader.
    /// - Parameters:
    ///   - isMaximized: A binding to a Boolean indicating whether the view is maximized in its context.
    ///   - content: The wrapped content.
    public init(isMaximized: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        _isMaximized = isMaximized
        _content = .constant(content)
    }
}

@available(tvOS, unavailable)
struct LayoutReader_Previews: PreviewProvider {
    static var previews: some View {
        LayoutReader(isMaximized: .constant(true)) {
            ZStack {
                Color.red
                    .ignoresSafeArea()
                Color.blue
            }
        }
        .previewDisplayName("Safe area ignored in LayoutReader")

        ZStack {
            Color.red
                .ignoresSafeArea()
            Color.blue
        }
        .previewDisplayName("Safe area ignored in ZStack")

        LayoutReader(isMaximized: .constant(true)) {
            Color.red
            Color.blue
        }
        .previewDisplayName("Simple LayoutReader")

        ZStack {
            Color.red
            Color.blue
        }
        .previewDisplayName("Simple ZStack")
    }
}
