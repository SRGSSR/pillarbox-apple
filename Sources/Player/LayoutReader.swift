//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// Layout information.
public struct LayoutInfo {
    /// A placeholder for unfilled layout information.
    public static var none: Self {
        .init(isMaximized: false, isFullScreen: false)
    }

    /// Return whether the view is maximized in its parent context.
    public let isMaximized: Bool
    /// Return whether the view covers the whole screen
    public let isFullScreen: Bool
}

/// A view which is able to determine whether it is maximized in its parent context or full screen. The view lays out
/// its children like a `ZStack`.
@available(tvOS, unavailable)
public struct LayoutReader<Content: View>: View {
    @Binding private var layoutInfo: LayoutInfo
    @Binding private var content: () -> Content

    public var body: some View {
        // Ignore the safe area to have support for safe area insets similar to a `ZStack`.
        LayoutReaderHost(layoutInfo: $layoutInfo) {
            ZStack {
                content()
            }
        }
        .ignoresSafeArea()
    }

    /// Create the layout reader.
    /// - Parameters:
    ///   - info: The layout information.
    ///   - content: The wrapped content.
    public init(layoutInfo: Binding<LayoutInfo>, @ViewBuilder content: @escaping () -> Content) {
        _layoutInfo = layoutInfo
        _content = .constant(content)
    }
}

@available(tvOS, unavailable)
struct LayoutReader_Previews: PreviewProvider {
    private struct IgnoredSafeAreaInLayoutReader: View {
        @State private var layoutInfo: LayoutInfo = .none

        var body: some View {
            LayoutReader(layoutInfo: $layoutInfo) {
                ZStack {
                    Color.red
                        .ignoresSafeArea()
                    Color.blue
                    VStack {
                        Text(layoutInfo.isMaximized ? "Maximized" : "Not maximized")
                        Text(layoutInfo.isFullScreen ? "Full screen" : "Not full screen")
                    }
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
        @State private var layoutInfo: LayoutInfo = .none

        var body: some View {
            LayoutReader(layoutInfo: $layoutInfo) {
                Color.red
                Color.blue
                VStack {
                    Text(layoutInfo.isMaximized ? "Maximized" : "Not maximized")
                    Text(layoutInfo.isFullScreen ? "Full screen" : "Not full screen")
                }
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

    private struct NonMaximizedLayoutReader: View {
        var body: some View {
            ZStack {
                SafeAreaInLayoutReader()
                    .frame(width: 400, height: 400)
            }
        }
    }

    private struct NonFullScreenLayoutReader: View {
        var body: some View {
            Color.yellow
                .sheet(isPresented: .constant(true)) {
                    SafeAreaInLayoutReader()
                        .interactiveDismissDisabled()
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
        NonMaximizedLayoutReader()
            .previewDisplayName("Non-maximized LayoutReader")
        NonFullScreenLayoutReader()
            .previewDisplayName("Non full-screen LayoutReader")
    }
}
