//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@available(tvOS, unavailable)
private struct PresentedView<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        content()
            .gesture(
                DragGesture(minimumDistance: 100)
                    .onEnded { value in
                        guard value.translation.height > 0 else { return }
                        dismiss()
                    }
            )
    }
}

extension View {
    @ViewBuilder
    func modal<Item, Content>(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content) -> some View where Item: Identifiable, Content: View {
#if os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            fullScreenCover(item: item) { item in
                PresentedView {
                    content(item)
                }
            }
        default:
            sheet(item: item, content: content)
        }
#else
        fullScreenCover(item: item, content: content)
#endif
    }
}
