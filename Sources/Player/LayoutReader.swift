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
        LayoutReaderHost(isMaximized: $isMaximized) {
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
    private struct IgnoredSafeAreaInLayoutReader: View {
        @State private var isMaximized = false

        var body: some View {
            LayoutReader(isMaximized: $isMaximized) {
                ZStack {
                    Color.red
                        .ignoresSafeArea()
                    Color.blue
                    Text(isMaximized ? "Maximized" : "Not maximized")
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

    private struct SafeAreaInLayoutReader: View {
        @State private var isMaximized = false

        var body: some View {
            LayoutReader(isMaximized: $isMaximized) {
                Color.red
                Color.blue
                Text(isMaximized ? "Maximized" : "Not maximized")
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
        IgnoredSafeAreaInLayoutReader()
            .previewDisplayName("Safe area ignored in LayoutReader")
        IgnoredSafeAreaInZStack()
            .previewDisplayName("Safe area ignored in ZStack")
        SafeAreaInLayoutReader()
            .previewDisplayName("Safe area in LayoutReader")
        SafeAreaInZStack()
            .previewDisplayName("Safe area in ZStack")
        VStack {
            SafeAreaInLayoutReader()
                .frame(width: 400, height: 400)
        }
        .previewDisplayName("Non-maximized LayoutReader")
    }
}
