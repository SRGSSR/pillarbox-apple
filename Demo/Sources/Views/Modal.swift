//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

#if os(iOS)

private struct ModalModifier<Item, Presented>: ViewModifier where Item: Identifiable, Presented: View {
    let item: Binding<Item?>
    @ViewBuilder let presented: (Item) -> Presented

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: item) { item in
                presented(item)
                    .modifier(PresentedModifier())
            }
    }
}

private struct PresentedModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 100)
                    .onEnded { value in
                        guard value.translation.height > 0 else { return }
                        dismiss()
                    }
            )
    }
}

#endif

extension View {
    func modal<Item, Content>(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content) -> some View where Item: Identifiable, Content: View {
#if os(iOS)
        modifier(ModalModifier(item: item, presented: content))
#else
        fullScreenCover(item: item, content: content)
#endif
    }
}
